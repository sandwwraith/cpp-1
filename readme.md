#Домашнее задание №1
В файле `add.asm` лежит код для сложения длинных чисел, в файлах `sub.asm` и `mul.asm` для вычитания и умножения соответственно.
В файле `inout.asm` содержатся функции для ввода-вывода, а также некоторые вспомогательные.

Программы написаны на ассемблере NASM для архитектуры x86-64 и для ОС Microsoft Windows (тестировалось на Windows 8.1).
Для построения достаточно запустить скрипт `build.bat`, удостоверившись, что пути к компилятору и линковщику прописаны в `PATH` и что на компьютере присутствует библиотека `msvcrt.dll`.
После этого в папке bin будут лежать исполняемые файлы.

Для проекта были использованы:

1.  [NASM for Windows](http://www.nasm.us/pub/nasm/releasebuilds/2.11.08/win32/)

2.  [GoLink](http://www.godevtool.com/)

3.  [Sublime Text 2](http://www.sublimetext.com/) с плагином [NASM x86 Assembly](https://github.com/Nessphoro/sublimeassembly)

