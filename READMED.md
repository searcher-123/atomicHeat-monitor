Пожелания и коментарии:
- Bombino 
цифры как будто черным контуром обведены. Оттого они выглядят неестественно. 
А можно бОльший градиент, а не только 3 цвета?
- DrCAD — 23.10.2023 18:38
а мне красный норм. приглушенно-смазаный. жёлтый лучше читается и по фону совпадает, если издалека, вот зелёный наверное будет плох.
может монохромный выбрать? в оранжевожелтом
и 0-333-500-850. а ещё лучше верхний номинал по штатной температуре подбирать. расчётом.
а. не 333. надо смотреть, нет ли в популярных модах поглотителя теплового, ниже 500 - и ставить ту температуру
по идее, можно минимальную видимую т брать за нижнюю грань цветового градиента, 500 всегда переходный. и 1000 тоже макс - даже особо подсветить. чуть ли не белым :)
- axelander — 24.10.2023 21:44
500 это важное переломное значение, там резонно сделать прям резкий переход 
- searcher_k — 24.10.2023 22:05
я за возможность переключать между красотой и читаемостью )
- EgorProxyn — 24.10.2023 22:53
а можно впендюрить возможность двигать... ммм, как это называется то, границу и степень размытия градиента?
в некоторых случаях может быть важно наблюдать именно переход, скажем, 690-700, для какого нибудь конкретного теста, но не включать же такую странную предустановку в стандарт
- DrCAD — 25.10.2023 21:17
формат. тик. тип. коорд. температура до сотых.


TODO:
- fix - при загрузки сейва с модом, падаем на том, что Такой gui уже существует у user
- fix - create_group - не создавать группу если кол-во выбранных entity == 0
- refactor - Dispatcher распилить на PlayerController
- refactor - вынести в отдельные файлы
- "atomic heat monitor" close button https://forums.factorio.com/viewtopic.php?t=98713

Кнопки:
--- Buttons:
--- - active/disable - active/disable heat group markers
--- - stop/start - stop/start recording into buffer, then stop - write to file
--- - select entities(add/delete)
--- - new group content - replace existed heat-group content
--- - edit group name
--- - delete group
--- - - delete markers
--- - - delete event callback links
--- - show filer - show/hide entity category
--- - - reactor button
--- - - heat-exchanger button
--- - - pipe button
--- -
--- - TODO 
--- - on_entity_destroy() + registry
--- - alt select
--- - 
--- - Edit heat group selector
--- - New heat group selector (shortcut & monitor button)