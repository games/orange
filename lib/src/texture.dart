part of orange;


var defaultSampler = new Sampler();


class Texture {
  gl.Texture data;
  int format;
  int internalFormat;
  int target;
}


class TextureManager {
  static TextureManager _shared = new TextureManager._internal();
  
  factory TextureManager() {
    return _shared;
  }
  
  Map<String, Texture> _textures;
  
  TextureManager._internal() {
    _textures = {};
  }
  
  Future<Texture> load(gl.RenderingContext ctx, Map descripton) {
    var completer = new Completer<Texture>();
    if(descripton == null) {
      completer.complete(null);
    } else {
      var url = descripton["path"];
      if(_textures.containsKey(url)) {
        completer.complete(_textures[url]);
      } else {
        var sampler = or(descripton["sampler"], defaultSampler);
        var texture = new Texture();
        texture.target = or(descripton["target"], gl.TEXTURE_2D);
        texture.internalFormat = or(descripton["internalFormat"], gl.RGBA);
        texture.format = or(descripton["format"], gl.RGBA);
        if(url.toUpperCase().endsWith(".DDS")) {
          _loadDDS(completer, ctx, url, texture, sampler);
        } else {
          _loadImage(completer, ctx, url, texture, sampler);
        }
      }
    }  
    return completer.future;
  }
  
  _loadImage(Completer completer, gl.RenderingContext ctx, String url, Texture texture, Sampler sampler) {
    var image = new html.ImageElement(src : url);
    image.onLoad.listen((_) {
      texture.data = ctx.createTexture();
      ctx.bindTexture(texture.target, texture.data);
      
      var usesMipMaps = ((sampler.minFilter == gl.NEAREST_MIPMAP_NEAREST) ||
          (sampler.minFilter == gl.LINEAR_MIPMAP_NEAREST) ||
          (sampler.minFilter == gl.NEAREST_MIPMAP_LINEAR) ||
          (sampler.minFilter == gl.LINEAR_MIPMAP_LINEAR));
      if(usesMipMaps || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
        image = _ensureImage(image);
      }
      ctx.bindTexture(texture.target, texture.data);
      ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, sampler.wrapS);
      ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, sampler.wrapT);
      ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
      ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
      ctx.texImage2D(texture.target, 0, texture.internalFormat, texture.format, gl.UNSIGNED_BYTE, image);
      if(usesMipMaps) {
        ctx.generateMipmap(texture.target);
      }
      ctx.bindTexture(texture.target, null);
      _textures[url] = texture;
      completer.complete(texture);
    }).onError(() {
      print("Failed to load image : $url");
      completer.completeError(null);
    });
  }
  
  _loadDDS(Completer completer, gl.RenderingContext ctx, String url, Texture texture, Sampler sampler) {
    var req = new html.HttpRequest();
    req.responseType = "arraybuffer";
    req.onLoad.listen((e) {
      texture.data = ctx.createTexture();
      ctx.bindTexture(texture.target, texture.data);

      var dds = _parseDDS(req.response, true);
      var mipmapCount = dds["mipmapCount"];
      var mipmaps = dds["mipmaps"];
      for(var i = 0; i < mipmapCount; i++){
        var m = mipmaps[i];
        ctx.compressedTexImage2D(gl.TEXTURE_2D, i, 
            dds["format"], 
            m["width"].toInt(), m["height"].toInt(), 0, m["data"]);
//        print([dds["format"], m["width"].toInt(), m["height"].toInt(), m["data"].length]);
      }
      ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
      ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
      
      _textures[url] = texture;
      completer.complete(texture);
    });
    req.open("GET", url);
    req.send();
  }
  
  _ensureImage(html.ImageElement source) {
    var img = source;
    var shouldResize = false;
    var width = source.width;
    if(!_isPowerOfTwo(width)) {
      width = _nextHighestPowerOfTwo(width);
      shouldResize = true;
    }
    var height = source.height;
    if(!_isPowerOfTwo(height)) {
      height = _nextHighestPowerOfTwo(height);
      shouldResize = true;
    }
    if(shouldResize) {
      var canvas = new html.CanvasElement();
      canvas.width = width;
      canvas.height = height;
      var graphics = canvas.context2D;
      graphics.drawImageScaled(source, 0, 0, width, height);
      img = canvas;
    }
    return img;
  }
  
  _isPowerOfTwo(int x) {
    return (x & (x - 1)) == 0;
  }
  
  _nextHighestPowerOfTwo(int x) {
    --x;
    for(var i = 1; i < 32; i <<= 1) {
      x = x | x >> i;
    }
    return x + 1;
  }
  
  _parseDDS( buffer, loadMipmaps ) {
    var dds = { "mipmaps": [], "width": 0, "height": 0, "format": null, "mipmapCount": 1 };
    // Adapted from @toji's DDS utils
    //  https://github.com/toji/webgl-texture-utils/blob/master/texture-util/dds.js

    // All values and structures referenced from:
    // http://msdn.microsoft.com/en-us/library/bb943991.aspx/

    var DDS_MAGIC = 0x20534444;

    var DDSD_CAPS = 0x1,
        DDSD_HEIGHT = 0x2,
        DDSD_WIDTH = 0x4,
        DDSD_PITCH = 0x8,
        DDSD_PIXELFORMAT = 0x1000,
        DDSD_MIPMAPCOUNT = 0x20000,
        DDSD_LINEARSIZE = 0x80000,
        DDSD_DEPTH = 0x800000;

    var DDSCAPS_COMPLEX = 0x8,
        DDSCAPS_MIPMAP = 0x400000,
        DDSCAPS_TEXTURE = 0x1000;

    var DDSCAPS2_CUBEMAP = 0x200,
        DDSCAPS2_CUBEMAP_POSITIVEX = 0x400,
        DDSCAPS2_CUBEMAP_NEGATIVEX = 0x800,
        DDSCAPS2_CUBEMAP_POSITIVEY = 0x1000,
        DDSCAPS2_CUBEMAP_NEGATIVEY = 0x2000,
        DDSCAPS2_CUBEMAP_POSITIVEZ = 0x4000,
        DDSCAPS2_CUBEMAP_NEGATIVEZ = 0x8000,
        DDSCAPS2_VOLUME = 0x200000;

    var DDPF_ALPHAPIXELS = 0x1,
        DDPF_ALPHA = 0x2,
        DDPF_FOURCC = 0x4,
        DDPF_RGB = 0x40,
        DDPF_YUV = 0x200,
        DDPF_LUMINANCE = 0x20000;

    fourCCToInt32( value ) {
      return value.codeUnitAt(0) +
          (value.codeUnitAt(1) << 8) +
          (value.codeUnitAt(2) << 16) +
          (value.codeUnitAt(3) << 24);
    }

    int32ToFourCC( value ) {
      return new String.fromCharCodes([
                                       value & 0xff,
                                       (value >> 8) & 0xff,
                                       (value >> 16) & 0xff,
                                       (value >> 24) & 0xff
                                       ]);
    }

    var FOURCC_DXT1 = fourCCToInt32("DXT1");
    var FOURCC_DXT3 = fourCCToInt32("DXT3");
    var FOURCC_DXT5 = fourCCToInt32("DXT5");

    var headerLengthInt = 31; // The header length in 32 bit ints

    // Offsets into the header array

    var off_magic = 0;

    var off_size = 1;
    var off_flags = 2;
    var off_height = 3;
    var off_width = 4;

    var off_mipmapCount = 7;

    var off_pfFlags = 20;
    var off_pfFourCC = 21;

    // Parse header

    var header = new Int32List.view( buffer, 0, headerLengthInt );

    if ( header[ off_magic ] != DDS_MAGIC ) {
      print( "ImageUtils.parseDDS(): Invalid magic number in DDS header" );
      return dds;
    }
  
    if ( (header[ off_pfFlags ] & DDPF_FOURCC) == 0 ) {
        print( "ImageUtils.parseDDS(): Unsupported format, must contain a FourCC code" );
        return dds;
    }
  
    var blockBytes;
  
    var fourCC = header[ off_pfFourCC ];
    
    print("$fourCC fourCC $FOURCC_DXT1 $FOURCC_DXT3 $FOURCC_DXT5");
  
    if( fourCC == FOURCC_DXT1 ) {
        blockBytes = 8;
        dds["format"] =  gl.CompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT;//   RGB_S3TC_DXT1_Format;
    } else if(fourCC == FOURCC_DXT3) {
        blockBytes = 16;
        dds["format"] = gl.CompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT;// RGBA_S3TC_DXT3_Format;
    } else if(fourCC == FOURCC_DXT5) {
        blockBytes = 16;
        dds["format"] = gl.CompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT;// RGBA_S3TC_DXT5_Format;
    } else {
        print( "ImageUtils.parseDDS(): Unsupported FourCC code: ${int32ToFourCC( fourCC )}" );
    }
  
    dds["mipmapCount"] = 1;
  
    if ( ( (header[ off_flags ] & DDSD_MIPMAPCOUNT) != 0) && (loadMipmaps != false) ) {
        dds["mipmapCount"] = math.max( 1, header[ off_mipmapCount ] );
    }
  
    dds["width"] = header[ off_width ];
    dds["height"] = header[ off_height ];
  
    var dataOffset = header[ off_size ] + 4;
  
    // Extract mipmaps buffers
    var width = dds["width"];
    var height = dds["height"];
  
    for ( var i = 0; i < dds["mipmapCount"]; i ++ ) {
      int dataLength = math.max( 4, width ) ~/ 4 * math.max( 4, height ) ~/ 4 * blockBytes;
      var byteArray = new Uint8List.view( buffer, dataOffset, dataLength);
  
      var mipmap = { "data": byteArray, "width": width, "height": height };
      dds["mipmaps"].add( mipmap );
  
      dataOffset += dataLength;
  
      width = math.max( width * 0.5, 1 );
      height = math.max( height * 0.5, 1 );
    }
    return dds;
  }
  
  
  
  
  
  
  _parseDDS2( buffer, loadMipmaps ) {

    var dds = { "mipmaps": [], "width": 0, "height": 0, "format": null, "mipmapCount": 1 };

    // Adapted from @toji's DDS utils
    //  https://github.com/toji/webgl-texture-utils/blob/master/texture-util/dds.js

    // All values and structures referenced from:
    // http://msdn.microsoft.com/en-us/library/bb943991.aspx/

    var DDS_MAGIC = 0x20534444;

    var DDSD_CAPS = 0x1,
      DDSD_HEIGHT = 0x2,
      DDSD_WIDTH = 0x4,
      DDSD_PITCH = 0x8,
      DDSD_PIXELFORMAT = 0x1000,
      DDSD_MIPMAPCOUNT = 0x20000,
      DDSD_LINEARSIZE = 0x80000,
      DDSD_DEPTH = 0x800000;

    var DDSCAPS_COMPLEX = 0x8,
      DDSCAPS_MIPMAP = 0x400000,
      DDSCAPS_TEXTURE = 0x1000;

    var DDSCAPS2_CUBEMAP = 0x200,
      DDSCAPS2_CUBEMAP_POSITIVEX = 0x400,
      DDSCAPS2_CUBEMAP_NEGATIVEX = 0x800,
      DDSCAPS2_CUBEMAP_POSITIVEY = 0x1000,
      DDSCAPS2_CUBEMAP_NEGATIVEY = 0x2000,
      DDSCAPS2_CUBEMAP_POSITIVEZ = 0x4000,
      DDSCAPS2_CUBEMAP_NEGATIVEZ = 0x8000,
      DDSCAPS2_VOLUME = 0x200000;

    var DDPF_ALPHAPIXELS = 0x1,
      DDPF_ALPHA = 0x2,
      DDPF_FOURCC = 0x4,
      DDPF_RGB = 0x40,
      DDPF_YUV = 0x200,
      DDPF_LUMINANCE = 0x20000;

    fourCCToInt32( value ) {

      return value.charCodeAt(0) +
        (value.charCodeAt(1) << 8) +
        (value.charCodeAt(2) << 16) +
        (value.charCodeAt(3) << 24);

    }

    int32ToFourCC( value ) {
      return new String.fromCharCodes([
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff]);
    }

    loadARGBMip( buffer, dataOffset, width, height ) {
      var dataLength = width*height*4;
      var srcBuffer = new Uint8List.view( buffer, dataOffset, dataLength );
      var byteArray = new Uint8List( dataLength );
      var dst = 0;
      var src = 0;
      for ( var y = 0; y < height; y++ ) {
        for ( var x = 0; x < width; x++ ) {
          var b = srcBuffer[src]; src++;
          var g = srcBuffer[src]; src++;
          var r = srcBuffer[src]; src++;
          var a = srcBuffer[src]; src++;
          byteArray[dst] = r; dst++;  //r
          byteArray[dst] = g; dst++;  //g
          byteArray[dst] = b; dst++;  //b
          byteArray[dst] = a; dst++;  //a
        }
      }
      return byteArray;
    }

    var FOURCC_DXT1 = fourCCToInt32("DXT1");
    var FOURCC_DXT3 = fourCCToInt32("DXT3");
    var FOURCC_DXT5 = fourCCToInt32("DXT5");

    var headerLengthInt = 31; // The header length in 32 bit ints

    // Offsets into the header array

    var off_magic = 0;

    var off_size = 1;
    var off_flags = 2;
    var off_height = 3;
    var off_width = 4;

    var off_mipmapCount = 7;

    var off_pfFlags = 20;
    var off_pfFourCC = 21;
    var off_RGBBitCount = 22;
    var off_RBitMask = 23;
    var off_GBitMask = 24;
    var off_BBitMask = 25;
    var off_ABitMask = 26;

    var off_caps = 27;
    var off_caps2 = 28;
    var off_caps3 = 29;
    var off_caps4 = 30;

    // Parse header

    var header = new Int32List.view( buffer, 0, headerLengthInt );

    if ( header[ off_magic ] !== DDS_MAGIC ) {

      print( "ImageUtils.parseDDS(): Invalid magic number in DDS header" );
      return dds;

    }

    if ( ! header[ off_pfFlags ] & DDPF_FOURCC ) {

      print( "ImageUtils.parseDDS(): Unsupported format, must contain a FourCC code" );
      return dds;

    }

    var blockBytes;

    var fourCC = header[ off_pfFourCC ];

    var isRGBAUncompressed = false;

    switch ( fourCC ) {

      case FOURCC_DXT1:

        blockBytes = 8;
        dds.format = THREE.RGB_S3TC_DXT1_Format;
        break;

      case FOURCC_DXT3:

        blockBytes = 16;
        dds.format = THREE.RGBA_S3TC_DXT3_Format;
        break;

      case FOURCC_DXT5:

        blockBytes = 16;
        dds.format = THREE.RGBA_S3TC_DXT5_Format;
        break;

      default:

        if( header[off_RGBBitCount] ==32 
          && header[off_RBitMask]&0xff0000
          && header[off_GBitMask]&0xff00 
          && header[off_BBitMask]&0xff
          && header[off_ABitMask]&0xff000000  ) {
          isRGBAUncompressed = true;
          blockBytes = 64;
//          dds["format"] = THREE.RGBAFormat;
          dds["format"] = 1021;
        } else {
          print([ "ImageUtils.parseDDS(): Unsupported FourCC code: ", int32ToFourCC( fourCC ) ]);
          return dds;
        }
    }

    dds["mipmapCount"] = 1;

    if ( header[ off_flags ] & DDSD_MIPMAPCOUNT && loadMipmaps != false ) {

      dds["mipmapCount"] = math.max( 1, header[ off_mipmapCount ] );

    }

    //TODO: Verify that all faces of the cubemap are present with DDSCAPS2_CUBEMAP_POSITIVEX, etc.

    dds["isCubemap"] = header[ off_caps2 ] & DDSCAPS2_CUBEMAP ? true : false;

    dds["width"] = header[ off_width ];
    dds["height"] = header[ off_height ];

    var dataOffset = header[ off_size ] + 4;

    // Extract mipmaps buffers

    var width = dds["width"];
    var height = dds["height"];

    var faces = dds["isCubemap"] ? 6 : 1;

    for ( var face = 0; face < faces; face ++ ) {

      for ( var i = 0; i < dds["mipmapCount"]; i ++ ) {

        var dataLength = 0;
        var byteArray;
        if( isRGBAUncompressed ) {
          byteArray = loadARGBMip( buffer, dataOffset, width, height );
          dataLength = byteArray.length;
        } else {
          dataLength = math.max( 4, width ) / 4 * math.max( 4, height ) / 4 * blockBytes;
          byteArray = new Uint8List.view( buffer, dataOffset, dataLength );
        }
        
        var mipmap = { "data": byteArray, "width": width, "height": height };
        dds["mipmaps"].push( mipmap );

        dataOffset += dataLength;

        width = math.max( width * 0.5, 1 );
        height = math.max( height * 0.5, 1 );

      }

      width = dds["width"];
      height = dds["height"];

    }

    return dds;

  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}