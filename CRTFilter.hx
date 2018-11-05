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
    import starling.textures.Texture;
	
    /**
     * Creates a CRT screen effect
     * @author Devon O.
     */
	class CRTFilter extends BaseFilter
	{
        private var fc0:Vector<Float> =  Vector.ofArray([0.0, .25, .50, 1.0]);
        private var fc1:Vector<Float> =  Vector.ofArray([Math.sqrt(.50), 2.5, 1.55, Math.PI]);
        private var fc2:Vector<Float> =  Vector.ofArray([2.2, 1.4, 2.0, .2]);
        private var fc3:Vector<Float> =  Vector.ofArray([3.5, 0.7, 1, 0.7]);
        private var fc4:Vector<Float> =  Vector.ofArray([1, 0, 256, 4]);
        private var fc5:Vector<Float> =  Vector.ofArray([1, 1, 1, 0.0000001]);
        
        private var time:Float = 0.0;
        private var _speed:Float = 10.0;
		public var red(get, set) : Float;
		public var green(get, set) : Float;
		public var blue(get, set) : Float;
		public var brightness(get, set) : Float;
		public var distortion(get, set) : Float;
		public var frequency(get, set) : Float;
		public var intensity(get, set) : Float;
		public var speed(get, set) : Float;

        /** Create a new CRTFilter */
        public function new(){
			super();
		};
       
          override private function setAgal():Void 
        {
            FRAGMENT_SHADER = "\n"+ 
          
               "\n"+ " mov ft0.xy, v0.xy"+
               "\n"+ " sub ft0.xy, v0.xy, fc0.zz"+
                
               "\n"+ " mov ft0.z, fc0.x"+
               "\n"+ " dp3 ft0.w, ft0.xyz, ft0.xyz"+
               "\n"+ " mul ft0.z, ft0.w, fc4.y"+
                
               "\n"+ " add ft0.w, fc0.w, ft0.z"+
               "\n"+ " mul ft0.w, ft0.w, ft0.z"+
               "\n"+ " mul ft0.xy, ft0.ww, ft0.xy"+
               "\n"+ " add ft0.xy, ft0.xy, v0.xy"+
               
               "\n"+ " tex ft2, ft0.xy, fs0<2d, clamp, nearest, mipnone>"+
                
               "\n"+ " sge ft3.x, ft0.x, fc0.x"+
               "\n"+ " sge ft3.y, ft0.y, fc0.x"+
               "\n"+ " slt ft3.z, ft0.x, fc0.w"+
               "\n"+ " slt ft3.w, ft0.y, fc0.w"+
               "\n"+ " mul ft3.x, ft3.x, ft3.y"+
              "\n"+ "  mul ft3.x, ft3.x, ft3.z"+
               "\n"+ " mul ft3.x, ft3.x, ft3.w"+
                
               "\n"+ " max ft4.x, ft2.x, ft2.y"+
               "\n"+ " max ft4.x, ft4.x, ft2.z"+
               "\n"+ " min ft4.y, ft2.x, ft2.y"+
               "\n"+ " min ft4.y, ft4.y, ft2.z"+
               "\n"+ " div ft4.y, ft4.y, fc2.z"+
               "\n"+ " add ft4.x, ft4.x, ft4.y"+
               "\n"+ " mov ft4.xyzw, ft4.xxxx"+
              "\n"+ "  mul ft4.xyzw, ft4.xyzw, ft3.xxxx"+

               "\n"+ " mov ft2.x, ft0.y"+
               "\n"+ " mul ft2.x, ft2.x, fc1.w"+
                //mul ft2.x, ft2.x, fc4.z
               "\n"+ " sin ft2.x, ft2.x"+
               "\n"+ " mul ft2.x, ft2.x, fc0.y"+
               "\n"+ " sat ft2.x, ft2.x"+
              "\n"+ "  mul ft2.x, ft2.x, fc0.y"+
              "\n"+ "  mul ft2.x, ft2.x, fc4.w"+
               "\n"+ " add ft2.x, ft2.x, fc0.w"+
                
              "\n"+ "  mov ft2.y, fc0.w"+
                
               "\n"+ " mov ft2.z, fc5.x"+
               "\n"+ " mul ft2.z, ft2.z, fc0.z"+
               "\n"+ " add ft2.z, ft2.z, ft0.y"+
               "\n"+ " mul ft2.z, ft2.z, fc1.w"+
               "\n"+ " mul ft2.z, ft2.z, fc3.x"+
               "\n"+ " sin ft2.z, ft2.z"+
               "\n"+ " mul ft2.z, ft2.z, fc2.w"+
               "\n"+ " add ft2.y, ft2.y, ft2.z"+
                
                "\n"+ "add ft2.z, ft0.y, fc5.x"+
               "\n"+ " mul ft2.z, ft2.z, fc1.w"+
               "\n"+ " mul ft2.z, ft2.z, fc2.z"+
               "\n"+ " sin ft2.z, ft2.z"+
               "\n"+ " mul ft2.z, ft2.z, fc2.w"+
               "\n"+ " add ft2.y, ft2.y, ft2.z"+
                
               "\n"+ " mul ft2.y, ft2.y, fc4.x"+
                
               "\n"+ " mul ft0.xyz, ft4.xyz, ft3.xxx"+
               "\n"+ " mul ft0.xyz, ft0.xyz, fc3.yzw"+
               "\n"+ " mul ft0.xyz, ft0.xyz, ft2.xxx"+
               "\n"+ " mul ft0.xyz, ft0.xyz, ft2.yyy"+
               
				"\n"+ "mul ft1.x, ft0.x, ft0.y"+
               "\n"+ " mul ft1.x, ft1.x, ft0.z"+
                
                // set output alpha to 1 or 0 depending on multiplied out color (solid black will have 0 alpha)
               "\n"+ " sge ft0.w, ft1.x, fc5.w"+
               "\n"+ " mul ft0.xyz, ft0.xyz, ft0.www"+
               "\n" + " mov oc, ft0";
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
            this.time += this._speed/512;
            fc5[0] = time;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.fc1, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.fc2, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, this.fc3, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, this.fc4, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, this.fc5, 1);
        
            super.activate(pass, context, texture);
        }
		
        /** Red */
        public function set_red(value:Float):Float { return this.fc3[1] = value; }
        public function get_red():Float { return this.fc3[1]; }
        
        /** Green */
        public function set_green(value:Float):Float { return this.fc3[2] = value; }
        public function get_green():Float { return this.fc3[2]; }
        
        /** Blue */
        public function set_blue(value:Float):Float { return this.fc3[3] = value; }
        public function get_blue():Float { return this.fc3[3]; }
        
        /** Brightness */
        public function set_brightness(value:Float):Float { return this.fc4[0] = value; }
        public function get_brightness():Float { return this.fc4[0]; }
        
        /** Distortion */
        public function set_distortion(value:Float):Float { return this.fc4[1] = value; }
        public function get_distortion():Float { return this.fc4[1]; }
        
        /** Scanline Frequency */
        public function set_frequency(value:Float):Float { return this.fc4[2] = value; }
        public function get_frequency():Float { return this.fc4[2]; }
        
        /** Scanline Intensity */
        public function set_intensity(value:Float):Float { return this.fc4[3] = value; }
        public function get_intensity():Float { return this.fc4[3]; }
        
        /** Speed */
        public function set_speed(value:Float):Float { return this._speed = value; };
        public function get_speed():Float { return this._speed; }
    }
