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
 
 */

package starling.filters;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import starling.textures.Texture;

/**
 * Creates a pen and ink cross hatched effect. 
 * Will only work in Context3DProfile.BASELINE mode 
 * and only on square textures with Power of Two width and height
 * @author Devon O.
 */
class CrossHatchFilter extends BaseFilter
{
    public var red(get, set) : Float;
    public var green(get, set) : Float;
    public var blue(get, set) : Float;

    private var _vars : Array<Float> = [1, .75, .50, .3465];
    private var _vars2 : Array<Float> = [10, 5, 0, 1];
    private var _color : Array<Float> = [1, 1, 1, 1];
    
    private var _red : Float = 1.0;
    private var _green : Float = 1.0;
    private var _blue : Float = 1.0;
    
    /** Create a new CrossHatchFilter */
    public function new()
    {
        super();
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = "";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        _vars2[0] = 10.0 / texture.width;
        _vars2[1] = 5.0 / texture.width;
        
        _color[0] = _red;
        _color[1] = _green;
        _color[2] = _blue;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _vars, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _vars2, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _color, 1);
        context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        
        super.activate(pass, context, texture);
    }
    
    /** Deactivate */
    override private function deactivate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
    }
    
    /** Red */
    private function get_red() : Float
    {
        return _red;
    }
    private function set_red(value : Float) : Float
    {
        _red = value;
        return value;
    }
    
    /** Green */
    private function get_green() : Float
    {
        return _green;
    }
    private function set_green(value : Float) : Float
    {
        _green = value;
        return value;
    }
    
    /** Blue */
    private function get_blue() : Float
    {
        return _blue;
    }
    private function set_blue(value : Float) : Float
    {
        _blue = value;
        return value;
    }
}
