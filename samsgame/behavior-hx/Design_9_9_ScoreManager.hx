package scripts;

import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;
import box2D.collision.shapes.B2Shape;

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

import com.stencyl.graphics.shaders.BasicShader;
import com.stencyl.graphics.shaders.GrayscaleShader;
import com.stencyl.graphics.shaders.SepiaShader;
import com.stencyl.graphics.shaders.InvertShader;
import com.stencyl.graphics.shaders.GrainShader;
import com.stencyl.graphics.shaders.ExternalShader;
import com.stencyl.graphics.shaders.InlineShader;
import com.stencyl.graphics.shaders.BlurShader;
import com.stencyl.graphics.shaders.SharpenShader;
import com.stencyl.graphics.shaders.ScanlineShader;
import com.stencyl.graphics.shaders.CSBShader;
import com.stencyl.graphics.shaders.HueShader;
import com.stencyl.graphics.shaders.TintShader;
import com.stencyl.graphics.shaders.BloomShader;



class Design_9_9_ScoreManager extends SceneScript
{
	public var _ScoreFont:Font;
	public var _XOffset:Float;
	public var _YOffset:Float;
	public var _MinimumDigits:Float;
	public var _CurrentScore:Float;
	public var _GameAttribute:String;
	public var _FormattedScore:String;
	public var _CurrentLength:Float;
	public var _Persistent:Bool;
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_FormatScore():Void
	{
		_FormattedScore = ("" + _CurrentScore);
		propertyChanged("_FormattedScore", _FormattedScore);
		_CurrentLength = asNumber((_MinimumDigits - ("" + _FormattedScore).length));
		propertyChanged("_CurrentLength", _CurrentLength);
		for(index0 in 0...Std.int(_CurrentLength))
		{
			_FormattedScore = (("" + "0") + ("" + _FormattedScore));
			propertyChanged("_FormattedScore", _FormattedScore);
		}
	}
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_UpdateGlobalScore():Void
	{
		if(_Persistent)
		{
			setGameAttribute(_GameAttribute, _CurrentScore);
		}
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_IncrementScore(__Amount:Float):Void
	{
		_CurrentScore += __Amount;
		propertyChanged("_CurrentScore", _CurrentScore);
		_customEvent_UpdateGlobalScore();
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_DecrementScore(__Amount:Float):Void
	{
		_CurrentScore -= __Amount;
		propertyChanged("_CurrentScore", _CurrentScore);
		_customEvent_UpdateGlobalScore();
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_SetScoreFont(__Font:Font):Void
	{
		_ScoreFont = __Font;
		propertyChanged("_ScoreFont", _ScoreFont);
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_SetDrawOffset(__Horizontal:Float, __Vertical:Float):Void
	{
		_XOffset = asNumber(__Horizontal);
		propertyChanged("_XOffset", _XOffset);
		_YOffset = asNumber(__Vertical);
		propertyChanged("_YOffset", _YOffset);
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_GetXOffset():Float
	{
		return _XOffset;
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_GetYOffset():Float
	{
		return _YOffset;
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_GetScore():Float
	{
		return _CurrentScore;
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_SetScore(__Score:Float):Void
	{
		_CurrentScore = asNumber(__Score);
		propertyChanged("_CurrentScore", _CurrentScore);
		_customEvent_UpdateGlobalScore();
	}
	
	/* ========================= Custom Block ========================= */
	public function _customBlock_GetFont():Font
	{
		return _ScoreFont;
	}
	
	
	public function new(dummy:Int, dummy2:Engine)
	{
		super();
		nameMap.set("Score Font", "_ScoreFont");
		nameMap.set("X Offset", "_XOffset");
		_XOffset = 0.0;
		nameMap.set("Y Offset", "_YOffset");
		_YOffset = 0.0;
		nameMap.set("Minimum Digits", "_MinimumDigits");
		_MinimumDigits = 0.0;
		nameMap.set("Current Score", "_CurrentScore");
		_CurrentScore = 0.0;
		nameMap.set("Game Attribute", "_GameAttribute");
		_GameAttribute = "";
		nameMap.set("Formatted Score", "_FormattedScore");
		_FormattedScore = "";
		nameMap.set("Current Length", "_CurrentLength");
		_CurrentLength = 0.0;
		nameMap.set("Persistent?", "_Persistent");
		_Persistent = false;
		
	}
	
	override public function init()
	{
		
		/* ======================== When Creating ========================= */
		_CurrentScore = asNumber(0);
		propertyChanged("_CurrentScore", _CurrentScore);
		_GameAttribute = "INTERNALGLOBALSCORE";
		propertyChanged("_GameAttribute", _GameAttribute);
		if(_Persistent)
		{
			if(!(((asNumber((getGameAttribute(_GameAttribute))) <= 0) || (asNumber((getGameAttribute(_GameAttribute))) >= 0))))
			{
				setGameAttribute(_GameAttribute, _CurrentScore);
			}
			else
			{
				_CurrentScore = asNumber(asNumber((getGameAttribute(_GameAttribute))));
				propertyChanged("_CurrentScore", _CurrentScore);
			}
		}
		
		/* ========================= When Drawing ========================= */
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				_customEvent_FormatScore();
				if((hasValue(_ScoreFont)))
				{
					g.setFont(_ScoreFont);
				}
				g.drawString("" + _FormattedScore, _XOffset, _YOffset);
			}
		});
		
	}
	
	override public function forwardMessage(msg:String)
	{
		
	}
}