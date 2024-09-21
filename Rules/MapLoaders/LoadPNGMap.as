// TERRITORY CONTROL MAP LOADER

#include "BasePNGLoader.as";
#include "MinimapHook.as";

namespace TC_color
{
	enum color
	{
		spawnruins = 0xff808000,
		coalmine = 0xff373750,
		merchant = 0xff7878ff,
		witchshack = 0xff7832e1,
		pumpjack = 0xff14507d,
		chickencoop = 0xff964619,
		scoutchicken = 0xffb96437,
		barbedwire = 0xff5f6473,
		ivy = 0xff49ac00,
		
		iron = 0xff5f5f5f,
		iron_bg = 0xff454545,
		plasteel = 0xffd1c59f,
		plasteel_bg = 0xff6e6753,
		glass = 0xff6d95a1,
		glass_bg = 0xff5a7a83,
		matter = 0xff50deb1
	};
}

class TCPNGLoader : PNGLoader
{
	TCPNGLoader()
	{
		super();
	}

	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);
		switch (pixel.color)
		{
			case TC_color::spawnruins:    spawnBlob(map, "ruins", offset, -1);         autotile(offset); break;
			case TC_color::coalmine:      spawnBlob(map, "coalmine", offset, -1);      autotile(offset); break;
			case TC_color::merchant:      spawnBlob(map, "merchant", offset, -1);      autotile(offset); break;
			case TC_color::witchshack:    spawnBlob(map, "witchshack", offset, -1);    autotile(offset); break;
			case TC_color::pumpjack:      spawnBlob(map, "pumpjack", offset, -1);      autotile(offset); break;
			case TC_color::chickencoop:   spawnBlob(map, "chickencoop", offset, -1);   autotile(offset); break;
			case TC_color::scoutchicken:  spawnBlob(map, "scoutchicken", offset, -1);  autotile(offset); break;
			case TC_color::barbedwire:    spawnBlob(map, "barbedwire", offset, -1);    autotile(offset); break;
			case TC_color::ivy:
			{
				CBlob@ ivy = spawnBlob(map, "ivy", offset, -1);
				ivy.setPosition(ivy.getPosition() + Vec2f(0, 16));
				autotile(offset);
				break;
			}
			
			case TC_color::iron:         map.SetTile(offset, CMap::tile_iron);                   break;
			//case TC_color::iron_bg:      map.SetTile(offset, CMap::tile_biron);                  break;
			case TC_color::plasteel:     map.SetTile(offset, CMap::tile_plasteel);               break;
			//case TC_color::plasteel_bg:  map.SetTile(offset, CMap::tile_bplasteel);              break;
			case TC_color::glass:        map.SetTile(offset, CMap::tile_glass);                  break;
			//case TC_color::glass_bg:     map.SetTile(offset, CMap::tile_bglass);                 break;
			case TC_color::matter:       map.SetTile(offset, CMap::tile_matter);                 break;
		}
	}
}

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("LOADING TERRITORY CONTROL PNG MAP " + fileName, 0xff66C6FF);
	
	getMap().legacyTileMinimap = false;

	TCPNGLoader loader();

	return loader.loadMap(map, fileName);
}
