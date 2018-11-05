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

 */

package starling.filters;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import starling.textures.Texture;

/**
 * The ChromakeyFilter will 'key out' a specified color (setting its alpha to 0)
 * @author Devon O.
 */
class ChromakeyFilter extends BaseFilter
{
    public var color(get, set) : Int;
    public var threshold(get, set) : Float;

    private var _vars : Array<Float> = [1, 1, 1, 1];
    
    private var _color : ColorObject;
    private var _threshold : Float;
    
    /**
     * @param	color		The color to remove
     * @param	threshold	The threshold test for the keyed color
     */
    public function new(color : Int = 0x00FF00, threshold : Float = .25)
    {
        super();
        _color = new ColorObject(color);
        _threshold = threshold;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = " tex ft0, v0, fs0<2d, repeat, linear, nomip> \n" +
                "sub ft2.x, ft0.x, fc0.x	 \n" +
                "mul ft2.x, ft2.x, ft2.x	 \n" +
                "sub ft2.y, ft0.y, fc0.y \n" +
                "mul ft2.y, ft2.y, ft2.y	 \n" +
                "sub ft2.z, ft0.z, fc0.z \n" +
                "mul ft2.z, ft2.z, ft2.z	 \n" +
                "add ft2.w, ft2.x, ft2.y \n" +
                "add ft2.w, ft2.w, ft2.z	 \n" +
                "sqt ft1.x, ft2.w \n" +
                "sge ft0.w, ft1.x, fc0.w \n" +
                "mov oc, ft0";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        _vars[0] = _color.r;
        _vars[1] = _color.g;
        _vars[2] = _color.b;
        _vars[3] = _threshold;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _vars, 1);
        context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        
        super.activate(pass, context, texture);
    }
    
    /** Deactivate */
    override private function deactivate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
    }
    
    /** Color */
    private function set_color(value : Int) : Int
    {
        _color.setColor(value);
        return value;
    }
    private function get_color() : Int
    {
        return _color.getColor();
    }
    
    /** Threshold */
    private function set_threshold(value : Float) : Float
    {
        _threshold = value;
        return value;
    }
    private function get_threshold() : Float
    {
        return _threshold;
    }
}


class ColorObject
{
    public var r : Float;
    public var g : Float;
    public var b : Float;
    
    public function new(color : Int)
    {
        setColor(color);
    }
    
    public function setColor(color : Int) : Void
    {
        var red : Int = color >> 16;
        var green : Int = as3hx.Compat.parseInt(color >> 8) & 0xFF;
        var blue : Int = color & 0xFF;
        
        r = red / 0xFF;
        g = green / 0xFF;
        b = blue / 0xFF;
    }
    
    public function getColor() : Int
    {
        var red : Int = as3hx.Compat.parseInt(r * 0xFF);
        var green : Int = as3hx.Compat.parseInt(g * 0xFF);
        var blue : Int = as3hx.Compat.parseInt(b * 0xFF);
        return as3hx.Compat.parseInt(red << 16 | green << 8 | blue);
    }
}