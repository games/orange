from pyffi.formats.dds import DdsFormat 





def convert():
	filename = 'D:/github/orange/models/ogre/GREATSWORD21.DDS'
	
	# texture = pyglet.image.load(filename)
	# texture.get_texture().save(filename.replace('.dds', '.png'))
	# texture.get_texture().save('/Users/z/aaa.png')
	
	stream = open(filename, 'rb')
	data = DdsFormat.Data()
	# data.inspect(stream)
	data.read(stream)
	
	f = open(filename.replace('.dds', '.png'), 'w')
	data.write(f)
	f.close()
	



if __name__ == '__main__':
	convert()


