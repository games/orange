import pyglet





def convert():
	filename = '/Users/z/workspace/github/orange/models/ogre/alric.dds'
	texture = pyglet.image.load(filename)
	texture.get_texture().save(filename.replace('.dds', '.png'))

	# texture.get_texture().save('/Users/z/aaa.png')



if __name__ == '__main__':
	convert()


