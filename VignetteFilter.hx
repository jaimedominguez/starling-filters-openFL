/**
 *	Copyright (c) 2014 Devon O. Wolfgang
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
     * Produces a vignette effect on Starling display objects.
     * @author Devon O.
     */
 
    class VignetteFilter extends BaseFilter {
        
        private var mCenter:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
        private var mVars:Vector<Float> =  Vector.ofArray([.50, .50, .50, .50]);
        
        private var mSepia1:Vector<Float> =  Vector.ofArray([0.393, 0.769, 0.189, 0.000]);
        private var mSepia2:Vector<Float> =  Vector.ofArray([0.349, 0.686, 0.168, 0.000]);
        private var mSepia3:Vector<Float> =  Vector.ofArray([0.272, 0.534, 0.131, 0.000]);
        
        private var mNoSepia1:Vector<Float> =  Vector.ofArray([1.0, 0.0, 0.0, 0.000]);
        private var mNoSepia2:Vector<Float> =  Vector.ofArray([0.0, 1.0, 0.0, 0.000]);
        private var mNoSepia3:Vector<Float> =  Vector.ofArray([0.0, 0.0, 1.0, 0.000]);
        
        private var _centerX:Float;
        private var _centerY:Float;
        private var _amount:Float;
        private var _size:Float;
        private var _radius:Float;
        private var _useSepia:Bool = true;
   
		public var centerX(get, set):Float;
        public var centerY(get, set):Float;
        public var amount(get, set):Float;
        public var size(get, set):Float;
        public var radius(get, set):Float;
        public var useSepia(get, set):Bool;
 
        /**
         * Creates a new VignetteFilter
         * @param   cx          center x of vignette relative to display object being filtered
         * @param   cy          center y of vignette relative to display object being filtered
         * @param   amount      how much should the effect be applied (smaller number is less noticable result).
         * @param   radius      the amount of inner bright light.
         * @param   size        the size of the effect
         * @param   sepia       Should image be in sepia color
         */
        public function new (cx:Float=0.5, cy:Float=0.5, amount:Float=0.6, radius:Float=1.0, size:Float=1, sepia:Bool=false)
        {
			super();
            this._centerX    = cx;
            this._centerY    = cy;
            this._amount     = amount;
            this._radius     = radius;
            this._size       = size;
            this._useSepia   = sepia;
        }
        
        /** Set AGAL */
        override private function setAgal():Void 
        {
            FRAGMENT_SHADER = "sub ft0.xy, v0.xy, fc0.xy"+
                "\n"+ " mov ft2.x, fc1.w"+
                 "\n"+ "mul ft2.x, ft2.x, fc1.z"+
                 "\n"+ "sub ft3.xy, ft0.xy, ft2.x"+ 
                 "\n"+ "mul ft4.x, ft3.x, ft3.x"+
                 "\n"+ "mul ft4.y, ft3.y, ft3.y"+
                 "\n"+ "add ft4.x, ft4.x, ft4.y"+
                 "\n"+ "sqt ft4.x, ft4.x"+
                 "\n"+ "dp3 ft4.y, ft2.xx, ft2.xx"+
                "\n"+ " sqt ft4.y, ft4.y"+
                "\n"+ " div ft5.x, ft4.x, ft4.y"+
                 "\n"+ "pow ft5.y, ft5.x, fc1.y"+
                 "\n"+ "mul ft5.z, fc1.x, ft5.y"+
                 "\n"+ "sat ft5.z, ft5.z"+
                 "\n"+ "min ft5.z, ft5.z, fc0.z"+
                "\n"+ " sub ft6, fc0.z, ft5.z"+
                 "\n"+ "tex ft1, v0, fs0<2d, clamp, linear, mipnone>"+
                
                // sepia  
                "\n"+ " dp3 ft2.x, ft1, fc2"+
                 "\n"+ "dp3 ft2.y, ft1, fc3"+
                 "\n"+ "dp3 ft2.z, ft1, fc4"+
                
                "\n" + " mul ft6.xyz, ft6.xyz, ft2.xyz"+
                 "\n"+ "mov ft6.w, ft1.w"+
                "\n" + " mov oc, ft6";
         
			
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
            var halfSize:Float = this._size * .50;
            mCenter[0] = this._centerX - halfSize;
            mCenter[1] = this._centerY - halfSize;
            
            mVars[0] = this._amount;
            mVars[1] = this._radius;
            mVars[3] = this._size;
            
			
			trace("activate SEPIA?:" + _useSepia);
            // to sepia or not to sepia
            var s1:Vector<Float> = _useSepia ? mSepia1 : mNoSepia1;
            var s2:Vector<Float> = _useSepia ? mSepia2 : mNoSepia2;
            var s3:Vector<Float> = _useSepia ? mSepia3 : mNoSepia3;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mCenter, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mVars,   1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, s1,      1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, s2,      1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, s3,      1);
            
            super.activate(pass, context, texture);
        }
        
        /** Center X position of effect relative to Display Object being filtered */
        public function get_centerX():Float { return this._centerX; }
        public function set_centerX(value:Float):Float { return this._centerX = value; }
        
        /** Center Y position of effect relative to Display Object being filtered */
        public function get_centerY():Float { return this._centerY; }
        public function set_centerY(value:Float):Float { return this._centerY = value; }
        
        /** Amount of effect (smaller value is less noticeable) */
        public function get_amount():Float { return this._amount; }
        public function set_amount(value:Float):Float { return this._amount = value; }
        
        /** Size of effect */
        public function get_size():Float { return this._size; }
        public function set_size(value:Float):Float { return this._size = value; }
        
        /** Radius of vignette center */
        public function get_radius():Float { return this._radius; }
        public function set_radius(value:Float):Float {return  this._radius = value; }
        
        /** Apply a sepia color to Display Object being filtered */
        public function get_useSepia():Bool { return this._useSepia; }
        public function set_useSepia(value:Bool):Bool { return this._useSepia = value; }
		
		
    }
