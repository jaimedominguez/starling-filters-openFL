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
 */

package starling.filters;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import openfl.Vector;
import starling.textures.Texture;

/**
 * Produces a Bloom/Glow effect with adjustable color properties.
 * @author Devon O.
 */
class BloomFilter extends BaseFilter
{
    public var red(get, set) : Float;
    public var green(get, set) : Float;
    public var blue(get, set) : Float;
    public var blur(get, set) : Float;

    
    private var fc0 : Vector<Float> = cast([0, 0, 0, 2.5], Vector<Float>);
    private var fc1 : Vector<Float> = cast([-1.0, 0.0, 1.0, 9.0], Vector<Float>);
    private var _color : Vector<Float> = cast([1.0, 1.0, 1.0, 1.0], Vector<Float>);
    
    private var _red : Float;
    private var _green : Float;
    private var _blue : Float;
    
    private var _blur : Float;
    
    /**
     * Create a new BloomFilter
     * @param blur          amount of blur
     * @param red           red value
     * @param green         green value
     * @param blue          blue value
     * @param numPasses     number of passes this filter should apply (1 pass = 1 drawcall)
     */
    public function new(blur : Float = 2.5, red : Float = 1, green : Float = 1, blue : Float = 1, numPasses : Int = 1)
    {
        super();
        _blur = blur;
        _red = red;
        _green = green;
        _blue = blue;
        
        this.numPasses = numPasses;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone>  \n" +  //original texture  
                
                //output
                "mov ft1, fc0.xxxx  \n" +
                
                //size
                "mov ft2.x, fc0.y  \n" +
                "mul ft2.x, ft2.x, fc0.w  \n" +
                "rcp ft2.x, ft2.x  \n" +
                "mov ft2.y, fc0.z  \n" +
                "mul ft2.y, ft2.y, fc0.w  \n" +
                "rcp ft2.y, ft2.y  \n" +
                
                // START UNWRAPPED LOOP
                
                //1
                "mov ft3.xy, fc1.xx  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //2
                "mov ft3.xy, fc1.xy  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //3
                "mov ft3.xy, fc1.xz  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //4
                "mov ft3.xy, fc1.yx  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //5
                "mov ft3.xy, fc1.yy  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //6
                "mov ft3.xy, fc1.yz  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //7
                "mov ft3.xy, fc1.zx  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //8
                "mov ft3.xy, fc1.zy  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                //9
                "mov ft3.xy, fc1.zz  \n" +
                "mul ft3.xy, ft3.xy, ft2.xy  \n" +
                "add ft3.xy, ft3.xy, v0.xy  \n" +
                "tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
                "add ft1, ft1, ft4  \n" +
                
                // END LOOP
                
                // average out
                "div ft1, ft1, fc1.wwww  \n" +
                "add ft1, ft1, ft0  \n" +
                
                // multiply by color
                " mul oc, ft1, fc2   \n";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        fc0[0] = 0;
        fc0[1] = texture.width;
        fc0[2] = texture.height;
        fc0[3] = 1 / _blur;
        
        _color[0] = _red;
        _color[1] = _green;
        _color[2] = _blue;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _color, 1);
        
        super.activate(pass, context, texture);
    }
    
    /** Red value */
    private function get_red() : Float
    {
        return _red;
    }
    private function set_red(value : Float) : Float
    {
        _red = value;
        return value;
    }
    
    /** Green value */
    private function get_green() : Float
    {
        return _green;
    }
    private function set_green(value : Float) : Float
    {
        _green = value;
        return value;
    }
    
    /** Blue value */
    private function get_blue() : Float
    {
        return _blue;
    }
    private function set_blue(value : Float) : Float
    {
        _blue = value;
        return value;
    }
    
    /** Blur amount */
    private function get_blur() : Float
    {
        return _blur;
    }
    private function set_blur(value : Float) : Float
    {
        _blur = value;
        return value;
    }
}
