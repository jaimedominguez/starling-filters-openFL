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
 */

package starling.filters;

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import starling.textures.Texture;

/**
 * Creates a 'God Rays' / fake volumetric light filter effect.
 * Not compatible with constrained profile
 * @author Devon O.
 */
class GodRaysFilter extends BaseFilter
{
    public var x(get, set) : Float;
    public var y(get, set) : Float;
    public var decay(get, set) : Float;
    public var exposure(get, set) : Float;
    public var weight(get, set) : Float;
    public var density(get, set) : Float;

    private var steps : Int;
    
    // lightx, lighty
    private var lightPos : Array<Float> = [.5, .5, 1, 1];
    
    // numsamples, density, numsamples * density, 1 / numsamples * density
    private var vars1 : Array<Float> = [1, 1, 1, 1];
    
    // weight, decay, exposure
    private var vars2 : Array<Float> = [1, 1, 1, 1];
    
    private var _x : Float = 0.0;
    private var _y : Float = 0.0;
    private var _weight : Float = .50;
    private var _decay : Float = .87;
    private var _exposure : Float = .35;
    private var _density : Float = 2.0;
    
    /**
     * Create a GodRaysFilter effect
     * @param	steps	    Number of samples to take along the ray path (maximum 32 with Context3DProfile.BASELINE)
     * @param   numPasses   Number of passes this filter should apply (1 pass = 1 drawcall)
     */
    public function new(steps : Int = 30, numPasses : Int = 1)
    {
        super();
        this.steps = steps;
        this.numPasses = numPasses;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        var frag : String = "";
        
        // Calculate vector from pixel to light source in screen space.
        frag += "sub ft0.xy, v0.xy, fc0.xy \n";
        
        // Divide by number of samples and scale by control factor.
        frag += "mul ft0.xy, ft0.xy, fc1.ww \n";
        
        // Store initial sample.
        frag += "tex ft1,  v0, fs0 <2d, clamp, linear, mipnone> \n";
        
        // Set up illumination decay factor.
        frag += "mov ft2.x, fc0.w \n";
        
        // Store the texcoords
        frag += "mov ft4.xy, v0.xy \n";
        
        var i : Int = 0;
        while (i < this.steps)
        
        // Step sample location along ray.{
            
            frag += "sub ft4.xy, ft4.xy, ft0.xy \n";
            
            // Retrieve sample at new location.
            frag += "tex ft3,  ft4.xy, fs0 <2d, clamp, linear, mipnone> \n";
            
            // Apply sample attenuation scale/decay factors.
            frag += "mul ft2.y, ft2.x, fc2.x \n";
            frag += "mul ft3.xyz, ft3.xyz, ft2.yyy \n";
            
            // Accumulate combined color.
            frag += "add ft1.xyz, ft1.xyz, ft3.xyz \n";
            
            // Update exponential decay factor.
            frag += "mul ft2.x, ft2.x, fc2.y \n";
            i++;
        }
        
        // Output final color with a further scale control factor.
        frag += "mul ft1.xyz, ft1.xyz, fc2.zzz \n";
        frag += "mov oc, ft1";
        
        FRAGMENT_SHADER = frag;
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    // light position
    {
        
        this.lightPos[0] = _x / texture.width;
        this.lightPos[1] = _y / texture.height;
        
        // numsamples, density, numsamples * density, 1 / numsamples * density
        this.vars1[0] = this.steps;
        this.vars1[1] = _density;
        this.vars1[2] = this.steps * this.vars1[1];
        this.vars1[3] = 1 / this.vars1[2];
        
        // weight, decay, exposure
        this.vars2[0] = _weight;
        this.vars2[1] = _decay;
        this.vars2[2] = _exposure;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.lightPos, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.vars1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.vars2, 1);
        context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        
        super.activate(pass, context, texture);
    }
    
    /** Deactivate */
    override private function deactivate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
    }
    
    /** X Position */
    private function set_x(value : Float) : Float
    {
        _x = value;
        return value;
    }
    private function get_x() : Float
    {
        return _x;
    }
    
    /** Y Position */
    private function set_y(value : Float) : Float
    {
        _y = value;
        return value;
    }
    private function get_y() : Float
    {
        return _y;
    }
    
    /** Decay */
    private function set_decay(value : Float) : Float
    {
        _decay = value;
        return value;
    }
    private function get_decay() : Float
    {
        return _decay;
    }
    
    /** Exposure */
    private function set_exposure(value : Float) : Float
    {
        _exposure = value;
        return value;
    }
    private function get_exposure() : Float
    {
        return _exposure;
    }
    
    /** Weight */
    private function set_weight(value : Float) : Float
    {
        _weight = value;
        return value;
    }
    private function get_weight() : Float
    {
        return _weight;
    }
    
    /** Density */
    private function set_density(value : Float) : Float
    {
        _density = value;
        return value;
    }
    private function get_density() : Float
    {
        return _density;
    }
}
