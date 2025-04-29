// TERRITORY CONTROL MAP LOADER

#include "BasePNGLoader.as";
#include "MinimapHook.as";
#include "MapSaver.as";

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
		lamppost = 0xffffdd26,

		iron = 0xff5f5f5f,
		iron_back = 0xff454545,
		plasteel = 0xffd1c59f,
		plasteel_back = 0xff6e6753,
		glass = 0xff6d95a1,
		glass_back = 0xff5a7a83,
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
				CBlob@ blob = spawnBlob(map, "ivy", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, 16));
				autotile(offset);
				break;
			}
			case TC_color::lamppost:
			{
				CBlob@ blob = spawnBlob(map, "lamppost", offset, -1);
				blob.setPosition(blob.getPosition() + Vec2f(0, -8));
				autotile(offset);
				break;
			}
			
			case TC_color::iron:           map.SetTile(offset, CMap::tile_iron);                   break;
			//case TC_color::iron_back:      map.SetTile(offset, CMap::tile_iron_back);              break;
			case TC_color::plasteel:       map.SetTile(offset, CMap::tile_plasteel);               break;
			//case TC_color::plasteel_back:  map.SetTile(offset, CMap::tile_plasteel_back);          break;
			case TC_color::glass:          map.SetTile(offset, CMap::tile_glass);                  break;
			case TC_color::glass_back:     map.SetTile(offset, CMap::tile_glass_back);             break;
			case TC_color::matter:         map.SetTile(offset, CMap::tile_matter);                 break;
		}
	}
}

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	TCPNGLoader loader();
	getMap().legacyTileMinimap = false;

	if (!isServer())
	{
		map.CreateTileMap(0, 0, 8.0f, "Sprites/world.png");
	}

	SetupBackground(map);

	if (LoadSavedMap(getRules(), map))
	{
		print("LOADING SAVED MAP", 0xff66C6FF);
		return true;
	}

	print("LOADING TERRITORY CONTROL PNG MAP " + fileName, 0xff66C6FF);
	return loader.loadMap(map, fileName);
}

void SetupBackground(CMap@ map)
{
	// sky
	map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
	map.CreateSkyGradient("Sprites/skygradient.png"); // override sky color with gradient

	// background
	map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, -40.0f), Vec2f(0.06f, 20.0f), color_white);
	map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  -100.0f), Vec2f(0.18f, 70.0f), color_white);
	map.AddBackground("Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, -220.0f), Vec2f(0.3f, 180.0f), color_white);

	// fade in
	SetScreenFlash(255,   0,   0,   0);
}
