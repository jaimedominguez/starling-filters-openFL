/**
 *	Copyright (c) 2013 Devon O. Wolfgang
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
	import openfl.display.Bitmap;
	import openfl.display.BitmapData;
    import starling.textures.Texture;
    
    /**
     * Creates a sepia toned scratched film effect
     * @author Devon O.
     */
	@:bitmap("E:/Dev/AppsAndGames/Haxe/BeekyrReloaded/assetsEmbed/_compileTime/textures/filmnoise.jpg") 
	private class NOISE extends BitmapData { }

	 
    class ScratchedFilmFilter extends BaseFilter
    {
        
        private var vars1:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
        private var vars2:Vector<Float> =  Vector.ofArray([1, 0, 1, 2]);
        
        private var sepiaRed:Vector<Float> =  Vector.ofArray([.393, .769, .189, 2]);
        private var sepiaGreen:Vector<Float> =  Vector.ofArray([.349, .686, .168, 2]);
        private var sepiaBlue:Vector<Float> =  Vector.ofArray([.272, .534, .131, 2]);
        
        private var filmNoise:Texture;
        
        private var time:Float = 0.0;
        
        private var _speed1:Float;
        private var _speed2:Float;
        private var _scratchIntensity:Float;
        private var _scratchWidth:Float;
        private var useSepia:Bool;
		

		public var speed1(get, set) : Float;
		public var speed2(get, set) : Float;
		public var scratchIntensity(get, set) : Float;
		public var scratchWidth(get, set) : Float;
	   
        /**
         * Creates a new ScratchedFilmFilter
         * @param   speed1              speed at which scrathes appear/disappear
         * @param   speed2              speed of horizontal scratch movement
         * @param   scratchIntensity    number of scratches
         * @param   scratchWidth        width of scratches
         */
        public function new(speed1:Float=.005, speed2:Float=.01, scratchIntensity:Float=.33, scratchWidth:Float=.02)
        {
			super();
           	this.filmNoise = Texture.fromBitmap(new Bitmap(new NOISE(0,0)), false, false, 1, "bgra", true);

            this._speed1 = speed1;
            this._speed2 = speed2;
            this._scratchIntensity = scratchIntensity;
            this._scratchWidth = scratchWidth;
        }
        
        /** Dispose */
        public override function dispose():Void
        {
            this.filmNoise.dispose();
            super.dispose();
        }
        
        /** Set AGAL */
        override private function setAgal():Void 
        {
            FRAGMENT_SHADER ="mov ft0.x, fc0.x"+
                 "\n"+ " mul ft0.x, ft0.x, fc1.x"+
                 "\n"+ " mov ft0.y, fc0.y"+
                 "\n"+ " mul ft0.y, ft0.y, fc1.x"+
                
                // img	
                 "\n"+ " tex ft1, v0, fs0<2d, clamp, linear, mipnone>"+
                
                 "\n"+ " add ft2.x, v0.x, ft0.y"+
                 "\n"+ " mov ft2.y, ft0.x"+
                
                // scratch 
                 "\n"+ " tex ft3, ft2.xy, fs1<2d, wrap, linear, mipnone>"+
                
                 "\n"+ " sub ft4.x, ft3.x, fc0.z"+
                 "\n"+ " mul ft4.x, ft4.x, fc1.w"+
                 "\n"+ " div ft3.x, ft4.x, fc0.w"+
                 "\n"+ " sub ft4.x, fc1.z, ft3.x"+
                 "\n"+ " abs ft4.x, ft4.x"+
                 "\n"+ " sub ft3.x, fc1.z, ft4.x"+
                 "\n"+ " max ft3.x, fc1.y, ft3.x"+
                 "\n"+ " mov ft3.w, fc1.z"+
                 "\n"+ " add ft5, ft3.xxxw, ft1"+
                
                // sepia
                 "\n"+ " dp3 ft6.x, ft5.xyz, fc2.xyz"+
                 "\n"+ " dp3 ft6.y, ft5.xyz, fc3.xyz"+
                 "\n"+ " dp3 ft6.z, ft5.xyz, fc4.xyz"+
				 "\n"+ " mov ft6.w, ft5.w"+
                 "\n" + " mov oc ft6";

        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        { 
            this.vars1[0] = this._speed1;
            this.vars1[1] = this._speed2;
            this.vars1[2] = this._scratchIntensity;
            this.vars1[3] = this._scratchWidth;
            
            this.vars2[0] = this.time ;
            
            context.setTextureAt(1, this.filmNoise.base);
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.vars1,         1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.vars2,         1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.sepiaRed,      1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, this.sepiaGreen,    1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, this.sepiaBlue,     1);
            
            super.activate(pass, context, texture);
            
            this.time += .05;
            if (this.time >= texture.width) this.time = 0.0;
        }
		
        /** Deactivate */
        override private function deactivate(pass:Int, context:Context3D, texture:Texture):Void 
        {
            context.setTextureAt(1, null);
        }
		
		   /** Amount of snow */
  
    public function get_speed1():Float { return this._speed1; }
    public function set_speed1(value:Float):Float{ return this._speed1 = value; }
   
    public function get_speed2():Float { return this._speed2; }
    public function set_speed2(value:Float):Float{ return this._speed2 = value; }
      
    public function get_scratchIntensity():Float { return this._scratchIntensity; }
    public function set_scratchIntensity(value:Float):Float{ return this._scratchIntensity = value; }
    
    public function get_scratchWidth():Float { return this._scratchWidth; }
    public function set_scratchWidth(value:Float):Float { return this._scratchWidth = value; }
	
	//public function get_centerX():Float { return this._centerX; }
	//public function set_centerX(value:Float):Float { return this._centerX = value; }

	/** Center Y position of effect relative to Display Object being filtered */
	//public function get_centerY():Float { return this._centerY; }
	//public function set_centerY(value:Float):Float { return this._centerY = value; }

	/** Amount of effect (smaller value is less noticeable) */
	/*public function get_amount():Float { return this._amount; }
	public function set_amount(value:Float):Float { return this._amount = value; }

	* Size of effect */
	//public function get_size():Float { return this._size; }
	//public function set_size(value:Float):Float { return this._size = value; }

	/** Radius of vignette center */
	//public function get_radius():Float { return this._radius; }
	//public function set_radius(value:Float):Float { return this._radius = value; }
	
	//public function useSepia(value:Bool):Bool { return useSepia = value; }
  
		
		
		
		
    }
