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
    import flash.geom.Point;
	import openfl.Vector;
  
	import openfl.Lib;
    import starling.textures.Texture;
    
    /**
     * Creates a bad VCR effect with static-y snow, offset red colors, and moving black bar(s)
     * @author Devon O.
     */
    class VCRFilter extends BaseFilter
    {
        private var snowVars:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
        private var offsetVars:Vector<Float> =  Vector.ofArray([0, 1, 0, 0]);
        private var trackingVars:Vector<Float> =  Vector.ofArray([1, 3, 1, 1]);
        private var randVars:Vector<Float> =  Vector.ofArray([12.9898, 4.1414, 43758.5453, 1]);
        
		public var snow(get, set) : Float;
		public var tracking(get, set) : Float;
		public var trackingBlur(get, set) : Float;
		public var trackingAmount(get, set) : Float;
		public var redOffsetX(get, set) : Float;
		public var redOffsetY(get, set) : Float;
		
		
		
        private var _snow:Float = .40;
        private var _tracking:Float = 4.0;
        private var _trackingBlur:Float = 1.25;
        private var _trackingAmount:Float = 6.0;
        private var redOffset:Point = new Point(.4, .4);
		
        /** Create a new VCR Filter */
        public function VCRFilter(){}
        
        /** Set AGAL */
        override private function setAgal():Void 
        {
            FRAGMENT_SHADER =
         
                // original texture
                 "\n"+ "tex ft0, v0, fs0<2d, clamp, linear, mipnone>"+
                
                // jack up red offset
                 "\n"+ "add ft1.xy, v0.xy, fc1.xy"+
                 "\n"+ "tex ft3, ft1.xy, fs0<2d, clamp, linear, mipnone>"+
                 "\n"+ "mov ft0.x, ft3.x"+
                
                // Random snow
                 "\n"+ "mov ft1.xy, v0.xy"+
                 "\n"+ "add ft1.xy, ft1.xy, fc0.xy"+
                 "\n"+ "mov ft1.zw, fc1.zz"+
                 "\n"+ "mov ft6.xy, fc3.xy"+
                 "\n"+ "mov ft6.zw, fc1.zz"+
                 "\n"+ "dp3 ft1.x, ft1, ft6"+
                 "\n"+ "sin ft1.x, ft1.x"+
                 "\n"+ "mul ft1.x, ft1.x, fc3.z"+
                 "\n"+ "frc ft1.x, ft1.x"+
                 "\n"+ "mov ft2.xyz, ft1.xxx"+
                 "\n"+ "mov ft2.w, ft0.w"+
                // multiply snow by snow amount
                 "\n"+ "mul ft2.xyz, ft2.xyz, fc0.zzz"+
                
                // tracking (black bar(s))
                 "\n"+ "mov ft1.x, v0.y"+
                 "\n"+ "mov ft1.y, fc2.x"+
                 "\n"+ "mul ft1.y, ft1.y, fc2.z"+
                 "\n"+ "mul ft1.x, ft1.x, fc2.y"+
                 "\n"+ "add ft1.x, ft1.x, ft1.y"+
                 "\n"+ "sin ft1.x, ft1.x"+
                "\n"+ " add ft1.x, ft1.x, fc2.w"+
                 "\n"+ "sat ft1.x, ft1.x"+
                
                // multiply black bar in
                 "\n"+ "mul ft0.xyz, ft0.xyz, ft1.xxx"+
                
                // add snow and original
                 "\n" + "add oc, ft0, ft2";
          
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
            snowVars[0] = Math.random();
            snowVars[1] = Math.random();
            snowVars[2] = this._snow;
            
            offsetVars[0] = -this.redOffset.x;
            offsetVars[1] = -this.redOffset.y;
            
            trackingVars[0] = Lib.getTimer() / 1000;
            trackingVars[1] = this._trackingAmount;
            trackingVars[2] = this._tracking;
            trackingVars[3] = this._trackingBlur;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, snowVars,       1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, offsetVars,     1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, trackingVars,   1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, randVars,       1);
            
            super.activate(pass, context, texture);
        }
		
        /** Amount of snow */
        public function get_snow():Float { return this._snow; }
        public function set_snow(value:Float):Float { return this._snow = value; }

        /** Speed of black bars */
        public function get_tracking():Float { return this._tracking; }
        public function set_tracking(value:Float):Float { return this._tracking = value; }

        /** Blur of black bars */
        public function get_trackingBlur():Float { return this._trackingBlur; }
        public function set_trackingBlur(value:Float):Float { return this._trackingBlur = value; }

        /** Size / Number of black bars (larger value = more smaller bars) */
        public function get_trackingAmount():Float { return this._trackingAmount; }
        public function set_trackingAmount(value:Float):Float { return this._trackingAmount = value; }

        /** Image red offset x */
        public function get_redOffsetX():Float { return this.redOffset.x*100; }
        public function set_redOffsetX(value:Float):Float { return this.redOffset.x = value/100; }

        /** Image red offset y */
        public function get_redOffsetY():Float { return this.redOffset.y*100; }
        public function set_redOffsetY(value:Float):Float { return this.redOffset.y = value/100; }
		
    }
