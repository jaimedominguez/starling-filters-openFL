/**
 * 
 *  
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
import starling.textures.Texture;

/**
 * Motion Blur filter for Starling Framework.
 * Only use with Context3DProfile.BASELINE (not compatible with constrained profile).
 * @author Devon O.
 */
class MotionBlurFilter extends BaseFilter
{
    public var angle(get, set) : Float;
    public var amount(get, set) : Float;

    private var vars : Array<Float> = [1, 1, 1, 1];
    
    private var steps : Int;
    
    private var _amount : Float;
    private var _angle : Float;
    
    /**
     * Creates a new MotionBlurFilter
     * @param	angle	angle of blur in radians
     * @param	amount	the amount of blur
     * @param	steps	the level of the blur. A higher number produces a better result, but with worse performance. Can only be set once.
     */
    public function new(angle : Float = 0.0, amount : Float = 1.0, steps : Int = 5, numPasses : Int = 1)
    {
        super();
        this._angle = angle;
        this._amount = clamp(amount, 0.0, 20.0);
        
        this.steps = as3hx.Compat.parseInt(clamp(steps, 1.0, 30.0));
        
        this.numPasses = numPasses;
        
        marginX = marginY = _amount * this.steps;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        var step : String = 
        "add ft0.xy, ft0.xy, fc0.xy \n" +
        "tex ft2, ft0.xy, fs0<2d, clamp, linear, nomip> \n" +
        "add ft1, ft1, ft2 \n";
        
        var fragmentProgramCode : String = 
        "mov ft0.xy, v0.xy \n" +
        "tex ft1, ft0.xy, fs0<2d, clamp, linear, nomip> \n";
        
        var numSteps : Int = as3hx.Compat.parseInt(this.steps - 1);
        for (i in 0...numSteps)
        {
            fragmentProgramCode += step;
        }
        
        fragmentProgramCode += "div oc, ft1, fc0.zzz";
        
        FRAGMENT_SHADER = fragmentProgramCode;
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        var tSize : Float = (texture.width + texture.height) * .50;
        this.vars[0] = this._amount * Math.cos(this._angle) / tSize;
        this.vars[1] = this._amount * Math.sin(this._angle) / tSize;
        this.vars[2] = this.steps;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.vars, 1);
        
        super.activate(pass, context, texture);
    }
    
    /** Clamp target between min and max */
    private function clamp(target : Float, min : Float, max : Float) : Float
    {
        if (target < min)
        {
            target = min;
        }
        if (target > max)
        {
            target = max;
        }
        return target;
    }
    
    /** Angle */
    private function get_angle() : Float
    {
        return _angle;
    }
    private function set_angle(value : Float) : Float
    {
        _angle = value;
        return value;
    }
    
    /** Amount */
    private function get_amount() : Float
    {
        return _amount;
    }
    private function set_amount(value : Float) : Float
    {
        _amount = clamp(value, 0, 20);
        marginX = marginY = _amount * this.steps;
        return value;
    }
}
