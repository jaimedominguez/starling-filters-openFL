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
 * Produces a Black and White "Ansel Adams" type effect
 * @author Devon O.
 */
class AnselFilter extends BaseFilter
{
    public var exposure(get, set) : Float;
    public var brightness(get, set) : Float;
    public var scale(get, set) : Float;
    public var bias(get, set) : Float;
    public var redCoeff(get, set) : Float;
    public var greenCoeff(get, set) : Float;
    public var blueCoeff(get, set) : Float;

    private var fc0 : Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
    private var fc1 : Vector<Float> =  Vector.ofArray([0.299, 0.587, 0.114, 0]);
    private var fc2 : Vector<Float> =  Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
    private var fc3 : Vector<Float> =  Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
    
    private var _exposure : Float;
    private var _brightness : Float;
    private var _scale : Float;
    private var _bias : Float;
    private var _redCoeff : Float = 1.0;
    private var _greenCoeff : Float = 1.0;
    private var _blueCoeff : Float = 1.0;
    
    /**
     * Create a new Ansel filter
     * @param exposure      Exposure
     * @param brightness    Brightness
     * @param scale         Scale
     * @param bias          Bias
     */
    public function new(exposure : Float = 1, brightness : Float = 1, scale : Float = 1, bias : Float = 0)
    {
        super();
        _exposure = exposure;
        _brightness = brightness;
        _scale = scale;
        _bias = bias;
    }
    
    /** Set AGAL */
    override private function setAgal() : Void
    {
        FRAGMENT_SHADER = "tex ft0, v0, fs0<2d, clamp, linear, mipnone> \n" +
                
                // exposure
                "exp ft1, ft0  \n" +
                "mul ft1, ft1, fc0.xxxx  \n" +
                "mul ft0, ft0, ft1  \n" +
                
                // coefficients * luma
                "mov ft1.xyz, fc2.xyz  \n" +
                "mul ft1.xyz, ft1.xyz, fc1.xyz  \n" +
                "mov ft1.w, fc1.w  \n" +
                
                "dp3 ft2.x, ft0, ft1  \n" +
                "mov ft2.yzw, ft2.xxx  \n" +
                
                // out * brightness
                "mul ft2.xyz, ft2.xyz, fc0.yyy  \n" +
                
                // scale and bias (for maximum contrast)
                "add ft2.xyz, ft2.xyz, fc3.yyy  \n" +
                "max ft2.xyz, ft2.xyz, fc1.www  \n" +
                "mul ft2.xyz, ft2.xyz, fc3.xxx  \n" +
                
                "mov ft2.w, ft0.w  \n" +
                "mov oc, ft2";
    }
    
    /** Activate */
    override private function activate(pass : Int, context : Context3D, texture : Texture) : Void
    {
        fc0[0] = _exposure;
        fc0[1] = _brightness;
        
        fc2[0] = _redCoeff;
        fc2[1] = _greenCoeff;
        fc2[2] = _blueCoeff;
        
        fc3[0] = _scale;
        fc3[1] = _bias;
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3, 1);
        
        super.activate(pass, context, texture);
    }
    
    /** Exposure */
    private function get_exposure() : Float
    {
        return _exposure;
    }
    private function set_exposure(value : Float) : Float
    {
        _exposure = value;
        return value;
    }
    
    /** Brightness */
    private function get_brightness() : Float
    {
        return _brightness;
    }
    private function set_brightness(value : Float) : Float
    {
        _brightness = value;
        return value;
    }
    
    /** Scale */
    private function get_scale() : Float
    {
        return _scale;
    }
    private function set_scale(value : Float) : Float
    {
        _scale = value;
        return value;
    }
    
    /** Bias */
    private function get_bias() : Float
    {
        return _bias;
    }
    private function set_bias(value : Float) : Float
    {
        _bias = value;
        return value;
    }
    
    /** Red Coefficient */
    private function get_redCoeff() : Float
    {
        return _redCoeff;
    }
    private function set_redCoeff(value : Float) : Float
    {
        _redCoeff = value;
        return value;
    }
    
    /** Green Coefficient */
    private function get_greenCoeff() : Float
    {
        return _greenCoeff;
    }
    private function set_greenCoeff(value : Float) : Float
    {
        _greenCoeff = value;
        return value;
    }
    
    /** Blue Coefficient */
    private function get_blueCoeff() : Float
    {
        return _blueCoeff;
    }
    private function set_blueCoeff(value : Float) : Float
    {
        _blueCoeff = value;
        return value;
    }
}
