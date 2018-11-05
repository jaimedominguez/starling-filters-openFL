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
 * Produces a "bleached out" effect
 * @author Devon O.
 */
class BleachFilter extends BaseFilter
{
    public var amount(get, set) : Float;

    private var fc0 : Vector<Float> =  Vector.ofArray([0.2125, 0.7154, 0.0721, 0.0]);
    private var fc1 : Vector<Float> =  Vector.ofArray([2.0, 2.0, 2.0, 2.0]);
    private var fc2 : Vector<Float> =  Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
    private var _vars : Vector<Float> =  Vector.ofArray([.45, 10.0, 1, 0]);
    
    private var _amount : Float;
    
    /**
     * Create a new Bleach Filter
     * @param amount    Amount of bleach to apply (between 0 and 2 is good)
     */
    public function new(amount : Float = 1.0)
    {
        super();
        _amount = amount;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone>  \n" +
                " dp4 ft1.x, ft0, fc0  \n" +
                "mov ft2.xyzw, ft1.xxxx  \n" +
                
                // amount of mix
                "sub ft1.x, ft1.x, fc3.x  \n" +
                "mul ft1.x, ft1.x, fc3.y  \n" +
                "sat ft1.x, ft1.x  \n" +
                "mov ft1.yzw, ft1.xxx  \n" +
                
                "mul ft3, ft0, fc1  \n" +
                "mul ft3, ft3, ft2  \n" +
                
                "sub ft4, fc2, ft0  \n" +
                "sub ft5, fc2, ft2  \n" +
                "mul ft4, ft4, ft5  \n" +
                "mul ft4, ft4, fc1  \n" +
                "sub ft4, fc2, ft4  \n" +
                
                "sub ft4, ft4, ft3  \n" +
                "mul ft4, ft4, ft1  \n" +
                "add ft4, ft4, ft3  \n" +
                
                // mix(original, result, amount);
                "sub ft4, ft4, ft0  \n" +
                "mul ft4, ft4, fc3.zzzz  \n" +
                "add oc, ft4, ft0  \n";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        _vars[2] = _amount;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, _vars, 1);
        
        super.activate(pass, context, texture);
    }
    
    /** Amount of bleach (between 0 and 2 is generally good) */
    private function get_amount() : Float
    {
        return _amount;
    }
    private function set_amount(value : Float) : Float
    {
        _amount = value;
        return value;
    }
}
