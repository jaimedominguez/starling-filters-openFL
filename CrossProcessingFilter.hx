/**
 *	Copyright (c) 2015 Devon O. Wolfgang
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
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import starling.textures.Texture;

/**
 * Cross Processing effect
 * @author Devon O.
 */

@:bitmap("E:/Dev/AppsAndGames/Haxe/BeekyrReloaded/assetsEmbed/_compileTime/textures/cross-processing.jpg") 
private class SAMPLE_SOURCE extends BitmapData { }
	 
 
class CrossProcessingFilter extends BaseFilter
{
    public var amount(get, set) : Float;
	
    
    private var sample : Texture;
    private var vars : Vector<Float> = Vector.ofArray([1, .50, 0, .0]);
    
    private var _amount : Float;
    
    /** Create a new CrossProcessingFilter */
    public function new()
    {
        super();
		this.sample = Texture.fromBitmap(new Bitmap(new SAMPLE_SOURCE(0,0)), false, false, 1, "bgra", true);
    }
    
    /** Dispose */
    override public function dispose() : Void
    {
        this.sample.dispose();
        super.dispose();
    }
    
    /** Set AGAL */
	
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone> \n" +
                
                "mov ft1.y, fc0.y \n" +
                
                // r
                "mov ft1.x, ft0.x \n" +
                "tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone> \n" +
                "mov ft3.x, ft2.x \n" +
                
                // g
                "mov ft1.x, ft0.y \n" +
                "tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone> \n" +
                "mov ft3.y, ft2.y \n" +
                
                // g
                "mov ft1.x, ft0.z \n" +
                "tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone> \n" +
                "mov ft3.z, ft2.z \n" +
                
                // ft2 = mix (ft0, ft3, fc0.x)
                "sub ft2.xyz, ft3.xyz, ft0.xyz \n" +
                "mul ft2.xyz, ft2.xyz, fc0.x \n" +
                "add ft2.xyz, ft2.xyz, ft0.xyz \n" +
                
                "mov ft0.xyz, ft2.xyz \n" +
                
                "mov oc, ft0 \n";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        this.vars[0] = this._amount;
        
        context.setTextureAt(1, this.sample.base);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.vars, 1);
        context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        
        super.activate(pass, context, texture);
    }
    
    /** Deactivate */
    override private function deactivate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        context.setTextureAt(1, null);
        context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
    }
    
    /** Amount */
    private function set_amount(value : Float) : Float
    {
        this._amount = value;
        return value;
    }
    private function get_amount() : Float
    {
        return this._amount;
    }
}

