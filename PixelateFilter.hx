/**
 *	Copyright (c) 2012 Devon O. Wolfgang
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 * 
 *  Ported to Starling 1.8 for openFL / Haxe by Jaime Dominguez to be used in 'Beekyr Reloaded' (c) 2018 Kaleidogames.
 */

package starling.filters;

	
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
	import openfl.Vector;
    import starling.textures.Texture;
	
    /**
     * Pixelates images (square 'pixels')
     * @author Devon O.
     */
    class PixelateFilter extends BaseFilter
    {
        public var pixelSize(get, set) : Int;
        private var vars:Vector<Float> = Vector.ofArray([1, 1, 1, 1]);
        private var _size:Int;
        
        /**
         * Creates a new PixelateFilter
         * @param   size	size of pixel effect
         */
      public function new(size:Int = 8, screenSizeX:Int = 1280, screenSizeY:Int = 720)
        {
			super();
            _size = size;
			
			vars [0] = _size / screenSizeX;
			vars [1] = _size / screenSizeY;
        }
        
        /** Set AGAL */
        private override function setAgal():Void
        {
            FRAGMENT_SHADER = "div ft0, v0, fc0 "+
               "\n"+ "frc ft1, ft0"+
               "\n"+  "sub ft0, ft0, ft1"+
               "\n"+  "mul ft0, ft0, fc0"+
               "\n"+  "tex oc, ft0, fs0<2d, clamp, linear, mipnone>";
           
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
			vars[0] = this._size / texture.width;
			vars[1] = this._size / texture.height;

            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vars, 1);
            super.activate(pass, context, texture);
        }
	
		
		public override function dispose():Void {
			super.dispose();
			//trace("DISPONSE PXIXELATE");	
		}
		
		
        
        /** Pixel Size */
        public function get_pixelSize():Int { return _size; }
        public function set_pixelSize(value:Int):Int { return _size = value; }
    }
