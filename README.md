# SM_SmartChests
Scrap Mechanic mod for automated inventory control

replace *\Scrap Mechanic\Survival\Scripts\game\util\pipes.lua with pipes.lua

Specialized containers have highest priority

Chests coloured in the lightest or darkest colours are single item containers, only accepts whatever item is in it's first inventory position, second highest priority

Chests colours specific 3rd row (2nd darkest) colours are type specific and accept any item that belongs to that type, third highest priority

Grey - Metal based blocks
Green - Wood based blocks
Yellow - Stone based blocks
Lime - Carpet, oil based blocks
Blue - Small/normal sized pipes
Red - Vehicle parts
Orange - Logic parts

Chests with 2nd row colours act as normal, lowest priority
