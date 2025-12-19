(async function(){
	require('events').EventEmitter.defaultMaxListeners = 30;
	const argv = (() => {
			const args = {};
			process.argv.slice(2).map( (element) => {
				const matches = element.match( '(?:[-]{1,2})([a-zA-Z0-9-]+)(?:=(.*))?');
				if ( matches ){
					args[matches[1]] = matches[2] ? matches[2].replace(/^['"]/, '').replace(/['"]$/, '') : true;
				}
			});
			return args;
		})(),
		fs = require('fs'),
		path = require('path'),
		{ spawn } = require('child_process'),
		{ PDFDocument } =  require('pdf-lib'),
		{ imageSizeFromFile } = require('image-size/fromFile'),
		colors = require('colors'),
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
		open = argv["open"] ? argv["open"] : false,
		/**
		 * Длина строки
		 */
		rightSpace = 20,
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
		readDirectory = function(dir_read){
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
			var cmd = ``;
			switch (require(`os`).platform().toLowerCase().replace(/[0-9]/g, ``).replace(`darwin`, `macos`)) {
				case `win`:
					// Открываем директорию с выделенным файлом
					file = file || '=';
					cmd = `explorer`;
					open && spawn(cmd, ['/select,', file], { detached: true }).unref();
					break;
				// Для остальных открываем директорию
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
			}
		};

	colors.enable();

	if(directory) {
		console.log(`Directory:`.padEnd(rightSpace, " ").bold.brightYellow + `${directory}`.bold.cyan);
		let files = [...await readDirectory(`${directory}`)],
			tempDir = path.join(directory, 'temp');

		/**
		* Директория оптимизированных изображений
		* Если директория не удалена и в ней есть изображения,
		* то оптимизация этих изображений будет пропущена.
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
			console.log(`Optimization:`.padEnd(rightSpace, " ").bold.brightYellow + path.basename(tmpImg).bold.cyan, {
				width: width,
				height: height,
				wRessize: wRessize
			});
			if(!await isFile(tmpImg)) {
				/**
				 * Если изображение не существует
				 */
				try {
					// Ресайз и Оптимизация
					await resize(oldImg, tmpImg, wRessize);
					await closeDelay(200);
				}catch(e) {
					console.log("Optimization error:".padEnd(rightSpace, " ").bold.brightRed + path.basename(tmpImg).underline.bold.brightRed + "\n");
					/**
					 * Завершаем работу скрипта при ошибке.
					 * Не удаляем временную директорию.
					 */
					process.exit();
				}
			}
		}
		let tempFiles = [...await readDirectory(tempDir)].map(f => path.join(tempDir, f));

		if(tempFiles.length == files.length && tempFiles.length > 0){
			/**
			 * Сборка PDF файла
			 */
			const pdfDoc = await PDFDocument.create();
			for(let file of tempFiles) {
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
				if(pdfImage){
					/**
					 * Масштабируем страницу
					 */
					pdfImage.scale(scale);
					/**
					 * Добавляем страницу
					 */
					console.log("Add page image:".padEnd(rightSpace, " ").bold.brightYellow + path.basename(file).bold.cyan);
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
			 *
			 * По имени директории задаём имя файла
			 *
			 */
			let pdfBytes = await pdfDoc.save();
			let fileName = `${name}.pdf`;
			let pdfFile = path.join(directory, fileName);
			fs.writeFileSync(pdfFile, pdfBytes);
			console.log(`Saving a pdf file:`.padEnd(rightSpace, " ").bold.brightYellow + fileName.bold.cyan);
			openExplorerIn(pdfFile);
		}
		/**
		 * Удаляем временную директорию с  оптимизированными изображениями
		 */
		fs.rmSync(tempDir, { recursive: true, force: true });
		console.log("\n" + "Temporary directory deleted".bold.brightYellow + "\n\n---------------------------------------------------\n");
	}else{
		console.log("The image directory is not specified");
		console.log("--dir=\"directory/scanned/images\"".padEnd(40, " ").bold.brightGreen + "Specify the directory with the scanned images");
		console.log("--open".padEnd(40, " ").bold.brightGreen + "Opening a directory at the end of the script\n");
	}
})();
