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
     * Produces a noise/film grain effect on Starling display objects.
     * @author Devon O.
     */
    class NoiseFilter extends BaseFilter {
        
        private var noiseVars:Vector<Float> =  Vector.ofArray([1, 1, 1, 0]);
        private var randVars:Vector<Float> =  Vector.ofArray([12.9898, 78.233, 43758.5453, Math.PI]);

        private var _seedX:Float;
        private var _seedY:Float;
        private var _amount:Float;
 
        /**
         * Create a new Noise Filter
         * @param amount    Amount of noise (between 0 and 2.0 is good)
         */
        public function new(amount:Float=.25)
        {
			super();
            _amount = amount;
            _seedX = Math.random();
            _seedY = Math.random();
        }
        
        /** Set AGAL*/
        private override function setAgal():Void
        {
            FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone> "+
                
                 "\n"+ "mov ft1.xy, v0.xy "+
                 "\n"+ "add ft1.xy, ft1.xy, fc0.xy "+
                 "\n"+ "mov ft6.xy, fc1.xy "+
                
                // 'improved' "canonical one-liner" noise function
                //@see http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
                 "\n"+ "dp3 ft1.x, ft1.xy, ft6.xy "+
                "\n"+ " div ft1.x, ft1.x, fc1.w "+
                 "\n"+ "frc ft1.x, ft1.x "+
                 "\n"+ "mul ft1.x, ft1.x, fc1.w "+
                 "\n"+ "sin ft1.x, ft1.x "+
                 "\n"+ "mul ft1.x, ft1.x, fc1.z "+
                "\n"+ " frc ft1.x, ft1.x "+
                
                // multiply by amount
                 "\n"+ "mul ft1.x, ft1.x, fc0.z "+
                
                 "\n"+ "sub ft0.xyz, ft0.xyz, ft1.xxx "+
                 "\n" + "mov oc, ft0";
         
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
        
            noiseVars[0] = Math.random();
            noiseVars[1] = noiseVars[0] + 1;//quicker seed generator.
            noiseVars[2] = _amount;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, noiseVars, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, randVars,  1);
            
            super.activate(pass, context, texture);
        }
        
        /** Random seed in x dimension (between 0 and 1) */
        public function get_seedX():Float { return _seedX; }
        public function set_seedX(value:Float):Void { _seedX = value; }
        
        /** Random seed in y dimension (between 0 and 1) */
        public function get_seedY():Float { return _seedY; }
        public function set_seedY(value:Float):Void { _seedY = value; }
        
        /** Amount of noise (between 0 and 2 is best) */
        public function get_amount():Float { return _amount; }
        public function set_amount(value:Float):Void { _amount = value; }
    }
