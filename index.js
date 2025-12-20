(async function(){
	require('events').EventEmitter.defaultMaxListeners = 30;
	const argv = (() => {
			const args = {};
			process.argv.slice(2).map( (element) => {
				const matches = element.match( '(?:[-]{1,2})([a-zA-Z0-9-]+)(?:=(.*))?');
				if ( matches ){
					args[matches[1]] = matches[2] ? matches[2].replace(/^['"]/, '').replace(/['"]$/, '') : "true";
				}
			});
			return args;
		})(),
		fs = require('fs'),
		path = require('path'),
		{ spawn } = require('child_process'),
		{ PDFDocument } =  require('pdf-lib'),
		{ imageSizeFromFile } = require('image-size/fromFile'),
		chalk = require('chalk'),
		/**
		 * Книжная
		 */
		wPortrait = 1130,
		/**
		 * Альбомная
		 */
		wLandscape = 1600,
		scale = .5,
		directory = argv["dir"] ? path.resolve(argv["dir"]) : false,
		open = argv["open"] ? (argv["open"].toLowerCase() === "true" || argv["open"].toLowerCase() === "1" || argv["open"].toLowerCase() === "yes" ? true : false) : false,
		/**
		 * Длина строки
		 */
		rightSpace = 25,
		/**
		 * Это Директория?
		 */
		isDir = function(dir_read){
			return new Promise(function(resolve, reject){
				try {
					let stats = fs.lstatSync(dir_read);
					if (stats.isDirectory()) {
						resolve(true);
					}else{
						resolve(false);
					}
				}catch (e) {
					resolve(false);
				}
			});
		},
		/**
		 * Это Файл?
		 */
		isFile = function(file_read) {
			return new Promise(function(resolve, reject) {
				try {
					const stats = fs.statSync (file_read)
					resolve(stats.isFile());
				}catch(e){
					resolve(false);
				}
			});
		},
		/**
		 * Вывод файлов из директории (1 уровень)
		 */
		readDirectoryImageFiles = function(dir_read){
			return new Promise(function(resolve, reject) {
				let files = fs.readdirSync(dir_read).filter(function(fn) {
						let ext = path.extname(fn).toLowerCase();
						switch(ext) {
							case '.jpg':
							case '.jpeg':
							case '.png':
								return true;
								break;
							default:
								return false;
						}
					});
				resolve(files);
			})
		},
		/**
		 * Для удаление PDF файлов
		 */
		readDirectoryPdfFiles = function(dir_read) {
			return new Promise(function(resolve, reject) {
				let files = fs.readdirSync(dir_read).filter(function(fn) {
					let ext = path.extname(fn).toLowerCase();
					switch(ext) {
							case '.pdf':
								return true;
								break;
							default:
								return false;
						}
				});
				resolve(files);
			});
		},
		/**
		 * Ресайз изображения + оптимизация
		 */
		resize = function(input, output, width) {
			return new Promise(function(resolve, reject){
				let app = "magick",
					args = [
						input,
						"-quality",
						"80",
						"-filter",
						"Lanczos",
						"-thumbnail",
						`${width}x`,
						output
					],
					ls = spawn(app, args);
				ls.stdout.on('data', (data) => {
					// log(`stdout: ${data}`);
				});
				ls.stderr.on('data', (data) => {
					console.log(`stderr: ${data}`);
				});
				ls.on('close', (code) => {
					if(code == 0){
						resolve(code);
					}else{
						reject(code);
					}
				});
			});
		},
		/**
		 * Пауза
		 */
		closeDelay = function(ms) {
			return new Promise(resolve => setTimeout(resolve, ms));
		},
		/**
		 * Открытие обрабатываемой директории с pdf файлом
		 */
		openExplorerIn = function(file) {
			/**
			 * Если не файл - выходим
			 */
			const stats = fs.statSync (file);
			if(!stats.isFile()) {
				return false;
			}
			/**
			win32 		- Windows
			linux 		- Linux
			darwin 		- MacOS

			aix 		- ?
			freebsd 	- ?
			openbsd 	- ?
			sunos 		- ?
			*/
			let cmd = ``;
			switch (require(`os`).platform().toLowerCase().replace(/[0-9]/g, ``).replace(`darwin`, `macos`)) {
				/**
				 * Открываем директорию с выделенным файлом
				 * Файл помечаем как выделенный
				 */
				case `win`:
					file = file || '=';
					cmd = `explorer`;
					open && spawn(cmd, ['/select,', file], { detached: true }).unref();
					break;
				/**
				 * Открываем директорию
				 * Как будет доступна система для разработки
				 * примем дефолтные значения для открытия директорий
				 * с пометкой файла как выделенный
				 * Пока оставим так:
				 */
				case `linux`:
					file = file || '/';
					file = path.dirname(file)
					cmd = `xdg-open`;
					open && spawn(cmd, [file], { detached: true }).unref();
					break;
				case `macos`:
					file = file || '/';
					file = file.dirname(file)
					cmd = `open`;
					open && spawn(cmd, [file], { detached: true }).unref();
					break;
				/**
				 * Эти системы пока не знаю
				 */
				case `aix`:
				case `freebsd`:
				case `openbsd`:
				case `sunos`:
					console.log(require(`os`).platform().toLowerCase().replace(/[0-9]/g, ``));
					break;
			}
		},
		log = console.log;

	/**
	 * Задан ли параметр и является ли параметр директорией
	 */
	if(directory && await isDir(directory)) {
		log(chalk.yellowBright(`Directory:`.padEnd(rightSpace, " ")) + chalk.bold.cyan(`${directory}`));
		let pdfFiles = [...await readDirectoryPdfFiles(`${directory}`)].map(fn => path.join(directory, fn));
		if(pdfFiles.length) {
			/**
			 * Если есть pdf файлы, то удаляем
			 */
			for(let pdf of pdfFiles){
				log(chalk.yellowBright(`Deleting the pdf file:`.padEnd(rightSpace, " ")) + chalk.bold.cyan(path.basename(pdf)));
				fs.unlinkSync(pdf);
			}
		}
		/**
		 * Получаем изображения
		 */
		let files = [...await readDirectoryImageFiles(`${directory}`)],
			tempDir = path.join(directory, 'temp');

		/**
		* Директория оптимизированных изображений
		* Если не существует создать
		*/
		if(!await isDir(tempDir)){
			fs.mkdirSync(tempDir);
		}

		/**
		 * Оптимизация
		 */
		for(let file of files) {
			// Оригинальное Изображение
			const oldImg = path.join(directory, file);
			// Временное Изображение
			const tmpImg = path.join(tempDir, file);
			// Определяем размеры изображений
			const { width, height } = await imageSizeFromFile(oldImg);
			// Задаём размер ресайза
			const wRessize = width > height ? wLandscape : wPortrait;
			log(chalk.yellowBright(`Optimization:`.padEnd(rightSpace, " ")) + chalk.bold.cyan(path.basename(tmpImg)), {
				width: width,
				height: height,
				wRessize: wRessize
			});
			/**
			 * Если директория не удалена и в ней есть изображения,
			 * то оптимизация этих изображений будет пропущена.
			 */
			if(!await isFile(tmpImg)) {
				/**
				 * Если изображение не существует
				 */
				try {
					// Ресайз и Оптимизация
					await resize(oldImg, tmpImg, wRessize);
					await closeDelay(200);
				}catch(e) {
					log(chalk.redBright("Optimization error:".padEnd(rightSpace, " ")) + chalk.bold.underline.redBright(path.basename(tmpImg)) + "\n");
					/**
					 * Завершаем работу скрипта при ошибке.
					 * Не удаляем временную директорию.
					 */
					process.exit();
				}
			}
		}
		/**
		 * Получаем оптимизированные изображения
		 */
		let tempFiles = [...await readDirectoryImageFiles(tempDir)].map(f => path.join(tempDir, f));

		if(tempFiles.length == files.length && tempFiles.length > 0){
			/**
			 * Сборка PDF файла
			 */
			const pdfDoc = await PDFDocument.create();
			for(let file of tempFiles) {
				/**
				 * Если это файл изображения
				 */
				if(await isFile(file)){
					// Расширение файла
					const ext = path.extname(file).toLowerCase();
					let image = await fs.readFileSync(file);
					let {width, height} = await imageSizeFromFile(file)
					/**
					 * Загружаем изображение в PDF файл
					 */
					let pdfImage;
					if(ext == '.jpg' || ext == '.jpeg'){
						pdfImage = await pdfDoc.embedJpg(image);
					}else if(ext == '.png'){
						pdfImage = await pdfDoc.embedPng(image);
					}
					/**
					 * Если изображение загружено
					 */
					if(pdfImage){
						/**
						 * Масштабируем страницу
						 */
						pdfImage.scale(scale);
						/**
						 * Добавляем страницу
						 */
						log(chalk.yellowBright("Add page image:".padEnd(rightSpace, " ")) + chalk.bold.cyan(path.basename(file)));
						let page = pdfDoc.addPage([width * scale, height * scale]);
						/**
						 * Рисуем изображение на странице
						 */
						page.drawImage(pdfImage, {
							x: 0,
							y: 0,
							width: width * scale,
							height: height * scale,
						});
					}
				}
			}
			/**
			 * Получаем имя директории
			 */
			let name = path.basename(directory);
			/**
			 * Автор
			 * Руководитель
			 * Создатель
			 */
			pdfDoc.setAuthor("ProjectSoft");
			pdfDoc.setProducer("ProjectSoft");
			pdfDoc.setCreator("pdf-lib, ProjectSoft");
			/**
			 * Заголовок
			 * Ключевые слова
			 * Тема (Описание)
			 *
			 * По имени директории устанавливаем название, ключевые слова, описание
			 *
			 */
			pdfDoc.setTitle(`${name}`);
			pdfDoc.setKeywords([`${name}`]);
			pdfDoc.setSubject(`${name}`);
			/**
			 * Устанавливаем время создания и модификации
			 */
			pdfDoc.setCreationDate(new Date());
			pdfDoc.setModificationDate(new Date());
			/**
			 * Сохраняем
			 */
			let pdfBytes = await pdfDoc.save();
			/**
			 * По имени директории задаём имя файла
			 */
			let fileName = `${name}.pdf`;
			let pdfFile = path.join(directory, fileName);
			/**
			 * Запись в файл
			 */
			fs.writeFileSync(pdfFile, pdfBytes);
			log(chalk.yellowBright(`Saving a pdf file:`.padEnd(rightSpace, " ")) + chalk.bold.cyan(fileName));
			/**
			 * Пытаемся открыть директорию
			 * Присутствие параметра --open задаёт эту возможность
			 */
			openExplorerIn(pdfFile);
		} else {
			/**
			 * Отсутствуют оптимизированные изображения
			 */
		}
		/**
		 * Удаляем временную директорию с  оптимизированными изображениями
		 */
		fs.rmSync(tempDir, { recursive: true, force: true });
		log("\n" + chalk.yellowBright("Temporary directory deleted") + "\n")
		if (chalk.supportsColor) {
			log("   " + chalk.white("".padEnd(15, "█")));
			log("   " + chalk.blue("".padEnd(15, "█")));
			log("   " + chalk.red("".padEnd(15, "█")));
			log(" ")
		}
		log(chalk.greenBright("---------------------------------------------------") + "\n");
		//log(chalk.supportsColor);
	}else{
		log(chalk.bold.redBright("The image directory is not specified"));
		let nrm = path.join("directory", "scanned", "images");
		console.log(("--dir=\"" + nrm + "\"").padEnd(40, " ") + "Specify the directory with the scanned images");
		console.log("--open".padEnd(40, " ") + "Opening a directory at the end of the script\n");
	}
})();
