/**
 *	Copyright (c) 2018 Devon O. Wolfgang 
 *  
 *  Main dev: Devon O. Wolfgang 
 *  Modified and fixed by: Jaime Dominguez (for KaleidoGames)
 * 
 *  This filter tries to simulate how it would look like if we were watching the game through and old school projector.
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

package starling.filters ;


	import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.geom.Point;
	import openfl.display.Bitmap;
    //import flash.utils.getTimer;
	import openfl.Lib;
	import openfl.Vector;
	import openfl.display.BitmapData;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.Stage;
    import starling.textures.Texture;
	
	@:bitmap("E:/Dev/AppsAndGames/Haxe/BeekyrReloaded/assetsEmbed/_compileTime/textures/filmnoise.jpg") 
	private class NOISE extends BitmapData { }
	
	

	class LampProjectorFilter extends BaseFilter {
		
	//[Embed(source="assets/filmnoise.jpg")]
   // public static const NOISE:Class;
	

	
	
    private var snowVars:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
    private var offsetVars:Vector<Float> =  Vector.ofArray([0, 1, 0, 0]);
    private var trackingVars:Vector<Float> =  Vector.ofArray([1, 3, 1, 1]);
	
	//rand vars:
	//1+2 rotation
	//2 rotation
	//3 Number of lines
	//4 nothing?
    private var randVars:Vector<Float> =  Vector.ofArray([10.9898,98, 43758.5453, 1]);

    private var scratchVars1:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
    private var scratchVars2:Vector<Float> =  Vector.ofArray([1, 0, 1, 2]);
	
	private var mCenter:Vector<Float> =  Vector.ofArray([1, 1, 1, 1]);
    private var mVars:Vector<Float> =  Vector.ofArray([.50, .50, .50, .50]);
	
	 private var filmNoise:Texture;
	
    private var _snow:Float = .13;
    private var redOffset:Point = new Point(-0.25, -0.05);
    
    private var _speed1:Float = .5;
    private var _speed2:Float = .1;
    private var _scratchIntensity:Float =  0.24;
    private var _scratchWidth:Float = 0.08;
    
    private var _centerX:Float = 0.5;
    private var _centerY:Float = 0.5;
    private var _amount:Float = 0.55;
    private var _size:Float = 0.5;
    private var _radius:Float = 2.1;
    
	private var _hasVariation:Bool = true;
	private var _screenSize:Point = new Point(1280, 720);
	
	
	public var snow(get, set) : Float;
	public var redOffsetX(get, set) : Float;
	public var redOffsetY(get, set) : Float;
	public var speed1(get, set) : Float;
	public var speed2(get, set) : Float;
	public var scratchIntensity(get, set) : Float;
	public var scratchWidth(get, set) : Float;
	public var centerX(get, set) : Float;
	public var centerY(get, set) : Float;
	public var amount(get, set) : Float;
	public var size(get, set) : Float;
	public var radius(get, set) : Float;
	public var hasVariation(get, set) : Bool;
       
    public function new() {
		super();	
		this.filmNoise = Texture.fromBitmap(new Bitmap(new NOISE(0,0)), false, false, 1, "bgra", true);
		redOffsetX = -0.2;
		redOffsetY = -0.05;
		
		//_screenSize = new Point (Starling.current.stageWidth, Starling.current.stageHeight);
	}
    
    /** Create Shaders */
    override private function setAgal():Void 
        {
            FRAGMENT_SHADER = "\n"+ "tex ft0, v0, fs0<2d, clamp, linear, mipnone>"+
            
            // jack up red offset
             "\n"+ " add ft1.xy, v0.xy, fc1.xy"+
             "\n"+ " tex ft3, ft1.xy, fs0<2d, clamp, linear, mipnone>"+
             "\n"+ " mov ft0.x, ft3.x"+

            // Random snow
             "\n"+ " mov ft1.xy, v0.xy"+
             "\n"+ " add ft1.xy, ft1.xy, fc0.xy"+
             "\n"+ " mov ft1.zw, fc1.zz"+
             "\n"+ " mov ft6.xy, fc3.xy"+
             "\n"+ " mov ft6.zw, fc1.zz"+
             "\n"+ " dp3 ft1.x, ft1, ft6"+
             "\n"+ " sin ft1.x, ft1.x"+
             "\n"+ " mul ft1.x, ft1.x, fc3.z"+
              "\n"+ "frc ft1.x, ft1.x"+
              "\n"+ "mov ft2.xyz, ft1.xxx"+
             "\n"+ " mov ft2.w, ft0.w"+
          
			// multiply snow by snow amount
             "\n"+ " mul ft2.xyz, ft2.xyz, fc0.zzz"+
            
            // vcr effect
             "\n"+ " add ft1, ft0, ft2"+
            
            // Scratch             
             "\n"+ " mov ft0.x, fc4.x"+
              "\n"+ "mul ft0.x, ft0.x, fc2.x"+
             "\n"+ " mov ft0.y, fc4.y"+
             "\n"+ " mul ft0.y, ft0.y, fc2.x"+
            
             "\n"+ " add ft2.x, v0.x, ft0.y"+
             "\n"+ " mov ft2.y, ft0.x"+
            
            // scratch texture
             "\n"+ " tex ft3, ft2.xy, fs1<2d, wrap, linear, mipnone>"+
            
              "\n"+ "sub ft4.x, ft3.x, fc4.z"+
              "\n"+ "mul ft4.x, ft4.x, fc5.w"+
              "\n"+ "div ft3.x, ft4.x, fc4.w"+
              "\n"+ "sub ft4.x, fc5.z, ft3.x"+
             "\n"+ " abs ft4.x, ft4.x"+
             "\n"+ " sub ft3.x, fc5.z, ft4.x"+
             "\n"+ " max ft3.x, fc5.y, ft3.x"+
             "\n"+ " mov ft3.w, fc5.z"+
             "\n"+ " add ft5, ft3.xxxw, ft1"+

			// Vignette sub
			  "\n"+ "sub ft0.xy, v0.xy, fc6.xy"+
			  "\n"+ "mov ft2.x, fc7.w"+
			  "\n"+ "mul ft2.x, ft2.x, fc7.z"+
			  "\n"+ "sub ft3.xy, ft0.xy, ft2.x"+
			  "\n"+ "mul ft4.x, ft3.x, ft3.x"+
			  "\n"+ "mul ft4.y, ft3.y, ft3.y"+
			  "\n"+ "add ft4.x, ft4.x, ft4.y"+
			  "\n"+ "sqt ft4.x, ft4.x"+
			  "\n"+ "dp3 ft4.y, ft2.xx, ft2.xx"+
			  "\n"+ "sqt ft4.y, ft4.y"+
			  "\n"+ "div ft7.x, ft4.x, ft4.y"+
			  "\n"+ "pow ft7.y, ft7.x, fc7.y"+
			  "\n"+ "mul ft7.z, fc7.x, ft7.y"+
			  "\n"+ "sat ft7.z, ft7.z"+
			  "\n"+ "min ft7.z, ft7.z, fc6.z"+
			  "\n"+ "sub ft6, fc6.z, ft7.z"+
			  "\n"+ "mul ft5.xyz , ft5.xyz , ft6.xyz "+
			//
			  "\n" + "mov oc, ft5";

       
    }
    
    private override function activate(pass:Int, context:Context3D, texture:Texture):Void
        {
        
        snowVars[0] = Math.random();
        snowVars[1] = Math.random();
        snowVars[2] = _snow;
        
        offsetVars[0] = -redOffset.x;
        offsetVars[1] = -redOffset.y;
		offsetVars[2] = redOffset.x;
		offsetVars[3] = redOffset.y;

        trackingVars[0] = Lib.getTimer() / 1000;
          
        scratchVars1[0] = speed1;
        scratchVars1[1] = speed2;
        scratchVars1[2] = scratchIntensity;
        scratchVars1[3] = scratchWidth;

		var halfSize:Float = _size * .50;
		mCenter[0] = (centerX * _screenSize.x) / texture.width - halfSize;
	    mCenter[1] = (centerY * _screenSize.y) / texture.height - halfSize;

        mVars[0] = _amount;
        mVars[1] = _radius;
        mVars[3] = _size;

		if (_hasVariation) {
			//center of light variation.
			mCenter[0]+=Math.random()*.02 - 0.01;
			mCenter[1]+=Math.random()*.02 - 0.01;
			
			//light strenght variation
			mVars[0] = Math.sin(trackingVars[0]) * 0.05+_amount;
			mVars[1] += Math.random()*.01 - 0.005;
			mVars[3] += Math.random() * .01 - 0.05;
		
			//red variation
			offsetVars[0] += Math.random()*.001 - 0.001;
			offsetVars[1] += Math.random() * 0.001 - 0.0005;
			
			//blue 
			offsetVars[2] = offsetVars[0];
			offsetVars[3] = offsetVars[1];
		}
        
       context.setTextureAt(1, filmNoise.base);
        
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, snowVars,     1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, offsetVars,   1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, trackingVars, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, randVars,     1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, scratchVars1, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, scratchVars2, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, mCenter, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7, mVars,   1);
          
		super.activate(pass, context, texture);

    }
	
	override private function deactivate(pass:Int, context:Context3D, texture:Texture):Void 
        {
            context.setTextureAt(1, null);
        }
		
	 override public function dispose() : Void
    {
        this.filmNoise.dispose();
        super.dispose();
    }
		
		
	
     /** Amount of snow */
    public function get_snow():Float { return this._snow; }
    public function set_snow(value:Float):Float { return this._snow = value; }
 
    /** Image red offset x */
	public function get_redOffsetX():Float { return this.redOffset.x*100; }
	public function set_redOffsetX(value:Float):Float { return this.redOffset.x = value/100; }

	/** Image red offset y */
	public function get_redOffsetY():Float { return this.redOffset.y*100; }
	public function set_redOffsetY(value:Float):Float { return this.redOffset.y = value/100; }
		

    public function get_speed1():Float { return this._speed1; }
    public function set_speed1(value:Float):Float{ return this._speed1 = value; }
   
    public function get_speed2():Float { return this._speed2; }
    public function set_speed2(value:Float):Float{ return this._speed2 = value; }
      
    public function get_scratchIntensity():Float { return this._scratchIntensity; }
    public function set_scratchIntensity(value:Float):Float{ return this._scratchIntensity = value; }
    
    public function get_scratchWidth():Float { return this._scratchWidth; }
    public function set_scratchWidth(value:Float):Float { return this._scratchWidth = value; }
	
	public function get_centerX():Float { return this._centerX; }
	public function set_centerX(value:Float):Float { return this._centerX = value; }

	/** Center Y position of effect relative to Display Object being filtered */
	public function get_centerY():Float { return this._centerY; }
	public function set_centerY(value:Float):Float { return this._centerY = value; }

	/** Amount of effect (smaller value is less noticeable) */
	public function get_amount():Float { return this._amount; }
	public function set_amount(value:Float):Float { return this._amount = value; }

	/** Size of effect */
	public function get_size():Float { return this._size; }
	public function set_size(value:Float):Float { return this._size = value; }

	/** Radius of vignette center */
	public function get_radius():Float { return this._radius; }
	public function set_radius(value:Float):Float { return this._radius = value; }
	
	//enables disables the variations in the light.
	public function get_hasVariation():Bool { return _hasVariation; }
	public function set_hasVariation(value:Bool):Bool { return _hasVariation = value; }
  
	//enables disables the variations in the light.
	public function setScreenSize(valueX:Float, valueY:Float):Point {
		return _screenSize = new Point(valueX,valueY);
	}
        
  
}
