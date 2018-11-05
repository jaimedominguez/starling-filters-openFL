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
 * 
 */

package starling.filters;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
	import openfl.Vector;
    import starling.textures.Texture;
	
    /**
     * Creates a posterization/quantization effect
     * @author Devon O.
     */
    
    class PosterizeFilter extends BaseFilter
    {
        private var vars:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
        
        private var _numColors:Int;
        private var _gamma:Float;
        
        /**
         * 
         * @param	numColors
         * @param	gamma
         */
        public function new (numColors:Int=8, gamma:Float=.60)
        {
			super();
            this._numColors = numColors;
            this._gamma = gamma;
        }
        
        /** Set AGAL */
        private override function setAgal():Void
        {
            FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, nearest, mipnone>"+
                 "\n"+ "pow ft0.xyz, ft0.xyz, fc0.yyy"+
                 "\n"+ "mul ft0.xyz, ft0.xyz, fc0.xxx"+
                 "\n"+ "frc ft1.xyz, ft0.xyz"+
                 "\n"+ "sub ft1.xyz, ft0.xyz, ft1.xyz"+
                 "\n"+ "div ft0.xyz, ft1.xyz, fc0.xxx"+
                 "\n"+ "pow ft0.xyz, ft0.xyz, fc0.zzz"+
                 "\n" + "mov oc, ft0";
          
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
            this.vars[0] = this._numColors;
            this.vars[1] = this._gamma;
            this.vars[2] = 1 / this._gamma;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.vars, 1);
            super.activate(pass, context, texture);
        }
        
        /** Number of Colors */
        public function get_numColors():Int { return _numColors; }
        public function set_numColors(value:Int):Void { _numColors = value; }
        
        /** Gamma */
        public function get_gamma():Float { return _gamma; }
        public function set_gamma(value:Float):Void { _gamma = value; }
    }
