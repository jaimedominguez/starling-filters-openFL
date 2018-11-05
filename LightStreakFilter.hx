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
 */

package starling.filters;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import starling.textures.Texture;

/**
 * Produces a light streak effect on images.
 * This filter deliberately uses 4 passes to produce a streak in 4 different compass points so may degrade performance.
 * Use with caution.
 * @author Devon O.
 */
class LightStreakFilter extends BaseFilter
{
    public var attenuation(get, set) : Float;
    public var angle(get, set) : Float;
    public var spread(get, set) : Float;
    public var boost(get, set) : Float;

    
    /** 0, unused, unused, unused */
    private var fc0 : Array<Float> = [0.0, 0.0, 0.0, 0.0];
    
    /** direction xy / texel size xy */
    private var fc1 : Array<Float> = [1.0, 1.0, 1.0, 1.0];
    
    /** samples, spread, attenuation, 1 */
    private var fc2 : Array<Float> = [1.0, 1.0, 1.0, 1.0];
    
    /** Number of samples */
    private var samples : Int = 0;
    
    /** Attenuation */
    private var _attenuation : Float = .60;
    
    /** Angle (in radians) */
    private var _angle : Float = 0;
    
    /** Spread */
    private var _spread : Float = .30;
    
    /** Boost */
    private var _boost : Float = 1.0;
    
    /**
     * Create a new LightStreak Filter
     * @param samples   number of samples/steps
     * @param passes    number of passes. Each pass will add a new streak with a 90 degree offset.
     */
    public function new(samples : Int = 10, passes : Int = 4)
    {
        super();
        this.samples = samples;
        this.numPasses = passes;
    }
    
    /** Create Shader program */
    override private function setAgal() : Void
    {
        var frag : String = "";
        
        // output
        frag += "mov ft1.xyzw, fc0.xxxx  \n";
        
        frag += "mov ft0.z, fc2.x  \n";
        frag += "pow ft0.z, ft0.z, fc2.y  \n";
        
        // counter
        frag += "mov ft0.w, fc0.x  \n";
        
        var i : Int = 0;
        while (i < this.samples)
        {
            frag += "mul ft2.x, ft0.z, ft0.w  \n";
            frag += "pow ft2.x, fc2.z, ft2.x  \n";
            
            frag += "mul ft0.xy, fc1.xy, ft0.zz  \n";
            frag += "mul ft0.xy, ft0.xy, ft0.ww  \n";
            frag += "mul ft0.xy, ft0.xy, fc1.zw  \n";
            frag += "add ft0.xy, ft0.xy, v0.xy  \n";
            
            frag += "tex ft3, ft0.xy, fs0 <2d, clamp, linear, mipnone>  \n";
            
            frag += "sat ft2.x, ft2.x  \n";
            
            frag += "mul ft3.xyzw, ft3.xyzw, ft2.xxxx  \n";
            frag += "add ft1, ft1, ft3  \n";
            
            // increment counter
            frag += "add ft0.w, ft0.w, fc2.w  \n";
            i++;
        }
        
        frag += "sat oc, ft1";
        
        FRAGMENT_SHADER = frag;
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    // samples, spread, attenuation
    {
        
        fc2[0] = this.samples;
        fc2[1] = this._spread;
        fc2[2] = this._attenuation;
        
        // angle (90 degrees each pass)
        var ang : Float = this._angle + (1.57079633 * pass);
        fc1[0] = Math.cos(ang) * this._boost;
        fc1[1] = Math.sin(ang) * this._boost;
        
        // texel size
        fc1[2] = 1 / texture.width;
        fc1[3] = 1 / texture.height;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2, 1);
        
        super.activate(pass, context, texture);
    }
    
    /** Attenuation */
    private function set_attenuation(value : Float) : Float
    {
        _attenuation = value;
        return value;
    }
    private function get_attenuation() : Float
    {
        return _attenuation;
    }
    
    /** Angle (in radians) */
    private function set_angle(value : Float) : Float
    {
        _angle = value;
        return value;
    }
    private function get_angle() : Float
    {
        return _angle;
    }
    
    /** Spread */
    private function set_spread(value : Float) : Float
    {
        _spread = value;
        return value;
    }
    private function get_spread() : Float
    {
        return _spread;
    }
    
    /** Boost (similar to spread, but adjusting the 2 independently can produce better results) */
    private function set_boost(value : Float) : Float
    {
        _boost = value;
        return value;
    }
    private function get_boost() : Float
    {
        return _boost;
    }
}
