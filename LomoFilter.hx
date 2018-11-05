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
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DProgramType;
	import openfl.Vector;
    import starling.textures.Texture;
	
    /**
     * Produces a vintage Lomo camera type hue shift effect
     * @author Devon O.
     */
    class LomoFilter extends BaseFilter
    {
        
        private var fc0:Vector<Float> =  Vector.ofArray([0.50, 1.0, 0.25, 0.99609375]);
        private var fc1:Vector<Float> =  Vector.ofArray([2.0, 0.14453125, 1, 1]);
        
        private var _amount:Float;
        
        /**
         * Create a new Lomo Filter
         * @param amount    Amount of filter to apply (between 0 and 1 is good)
         */
        public function new(amount:Float=.75)
        {
			super();
            this._amount = amount;
        }
        
        /** Set AGAL */
        override private function setAgal():Void 
        {
            FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone>"+
            
           "\n"+ " mov ft1, ft0"+
            
            "\n"+ "slt ft2.x, ft1.x, fc0.x"+
           "\n"+ " mul ft2.x, ft2.x, ft1.x"+
            "\n"+ "sge ft2.y, ft1.x, fc0.x"+
            "\n"+ "sub ft2.z, fc0.y, ft1.x"+
            "\n"+ "mul ft2.y, ft2.y, ft2.z"+
            "\n"+ "add ft2.x, ft2.x, ft2.y"+
            
            "\n"+ "mul ft2.x, ft2.x, ft2.x"+
            "\n"+ "mul ft2.x, ft2.x, ft2.x"+
            "\n"+ "div ft2.x, ft2.x, fc0.z"+
            "\n"+ "div ft2.x, ft2.x, fc0.y"+
            
            "\n"+ "slt ft3.x, ft0.x, fc0.x"+
            "\n"+ "mul ft3.x, ft3.x, ft2.x"+
            "\n"+ "sge ft3.y, ft0.x, fc0.x"+
            "\n"+ "sub ft3.z, fc0.w, ft2.x"+
            "\n"+ "mul ft3.y, ft3.y, ft3.z"+
            "\n"+ "add ft3.x, ft3.x, ft3.y"+
            
            // RED
            "\n"+ "sat ft1.x, ft3.x"+
            
            "\n"+ "slt ft2.x, ft0.y, fc0.x"+
            "\n"+ "mul ft2.x, ft2.x, ft0.y"+
            "\n"+ "sge ft2.y, ft0.y, fc0.x"+
            "\n"+ "sub ft2.z, fc0.y, ft0.y"+
            "\n"+ "mul ft2.y, ft2.y, ft2.z"+
            "\n"+ "add ft2.x, ft2.x, ft2.y"+
            
           "\n"+ " mul ft2.x, ft2.x, ft2.x"+
           "\n"+ " div ft2.x, ft2.x, fc0.x"+
            
            "\n"+ "slt ft3.x, ft0.y, fc0.x"+
            "\n"+ "mul ft3.x, ft3.x, ft2.x"+
            "\n"+ "sge ft3.y, ft0.y, fc0.x"+
            "\n"+ "sub ft3.z, fc0.w, ft2.x"+
            "\n"+ "mul ft3.y, ft3.y, ft3.z"+
            "\n"+ "add ft3.x, ft3.x, ft3.y"+
            
            // GREEN
            "\n"+ "sat ft1.y, ft3.x"+
            
            "\n"+ "div ft3.x, ft0.z, fc1.x"+
           "\n"+ "add ft3.x, ft3.x, fc1.y"+
            
            // BLUE
            "\n"+ "sat ft1.z, ft3.x"+
            
            // mix output ft0, ft1, amount
            "\n"+ "sub ft6, ft1, ft0"+
            "\n"+ "mul ft6, ft6, fc1.z"+
            "\n" + "add oc, ft6, ft0";
            
           
        }
        
        /** Activate */
        private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
            fc1[2] = this._amount;
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1, 1);
            context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            
            super.activate(pass, context, texture);
        }
        
        /** Deactivate */
        override private function deactivate(pass:Int, context:Context3D, texture:Texture):Void 
        {
            context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
        }
        
        /** Amount of effect (between 0 and 1 is generally good) */
        public function get_amount():Float { return _amount; }
        public function set_amount(value:Float):Void { _amount = value; }
    }
