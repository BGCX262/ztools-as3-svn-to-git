package zTools.utils
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * 影片剪辑扩展工具类
	 * 
	 * @author Zivn
	 */	
	public class AnimationUtil
	{		
		private static const FLAG_SEPARATOR:String = '_';	
		
		private static const FLAG_STOP:String = 'stop';	
		private static const FLAG_GOPLAY:String = 'goplay';		
		private static const FLAG_GOSTOP:String = 'gostop';		
		private static const FLAG_EXTEND:String = 'extend';	
		private static const FLAG_SHOW:String = 'show';	
		private static const FLAG_HIDE:String = 'hide';
		
		private static function extendChildLabel(movieClip:MovieClip, childName:String):void
		{
			var childClip:MovieClip = movieClip.getChildByName(childName) as MovieClip;
			
			if (childClip)
			{
				AnimationUtil.extendLabel(childClip);
			}
		}
		
		private static function addChildListener(movieClip:MovieClip, childName:String, listens:Array):void
		{			
			var child:DisplayObject = movieClip.getChildByName(childName) as DisplayObject;
			
			if (child)
			{
				for each (var listen:Array in listens)
				{
					if (!child.hasEventListener(listen[0]))
					{
						if (listen[0] == MouseEvent.CLICK && child is MovieClip)
						{
							(child as MovieClip).buttonMode = true;
						}
						
						child.addEventListener(listen[0], listen[1]);
					}
				}
			}	
		}
		
		private static function showChild(movieClip:MovieClip, childName:String):void
		{			
			var child:DisplayObject = movieClip.getChildByName(childName) as DisplayObject;
			
			if (child)
			{
				child.visible = true;
			}	
		}
		
		private static function hideChild(movieClip:MovieClip, childName:String):void
		{			
			var child:DisplayObject = movieClip.getChildByName(childName) as DisplayObject;
			
			if (child)
			{
				child.visible = false;
			}
		}
		
		private static function checkFrame(movieClip:MovieClip):void
		{
			var funcInfos:Array = movieClip.frameFunctions[movieClip.currentFrame];
			
			for each (var funcInfo:Array in funcInfos)
			{
				if (funcInfo.length == 1)
				{
					funcInfo[0]();
				}
				else if (funcInfo.length == 2)
				{
					funcInfo[0].apply(null, funcInfo[1]);
				}
			}
		}
		
		/**
		 * 扩展影片剪辑的帧标签功能<br/><br/>
		 * 
		 * ------------------ 目前支持的功能标签 ------------------<br/>
		 * 　　stop_x：停止<br/>
		 * 　　goplay_n_x：转到第n帧并播放<br/>
		 * 　　gostop_n_x：转到第n帧并停止<br/>
		 * 　　extend_name_x：扩展名为name的影片剪辑的帧标签功能<br/>
		 * 　　show_name_x：将名为name的影片剪辑设置为可见<br/>
		 * 　　hide_name_x：将名为name的影片剪辑设置为隐藏<br/><br/>
		 * 
		 * 　　x为标签重复时添加的标示字符串，内容任意，但须确保在时间轴内唯一;<br/>
		 * 　　可见和隐藏通过visible属性实现;<br/><br/>
		 *  
		 * @param movieClip 要扩展的影片剪辑
		 */		
		public static function extendLabel(movieClip:MovieClip):void
		{		
			if (!movieClip.hasOwnProperty('frameFunctions'))
			{			
				movieClip.frameFunctions = [];
			}
			
			var checkFrames:Array = [];
			var frameLabels:Array = movieClip.currentLabels;
			
			for each(var frameLabel:FrameLabel in frameLabels)
			{							
				var frame:uint = frameLabel.frame;
				var scripts:Array = frameLabel.name.split(',');
				
				if (!movieClip.frameFunctions[frame])
				{
					movieClip.frameFunctions[frame] = [];
				}
				
				for each (var script:String in scripts)
				{
					var funcInfo:Array = script.split(StringUtil.trim(FLAG_SEPARATOR));
					
					if (funcInfo[0] == FLAG_STOP)
					{
						movieClip.frameFunctions[frame].push([movieClip.stop]);
					}
					else if (funcInfo[0] == FLAG_GOPLAY)
					{
						movieClip.frameFunctions[frame].push([movieClip.gotoAndPlay, funcInfo.slice(1, 2)]);								
					}
					else if (funcInfo[0] == FLAG_GOSTOP)
					{
						movieClip.frameFunctions[frame].push([movieClip.gotoAndStop, funcInfo.slice(1, 2)]);
					}
					else if (funcInfo[0] == FLAG_EXTEND)
					{
						movieClip.frameFunctions[frame].push([AnimationUtil.extendChildLabel, [movieClip].concat(funcInfo.slice(1, 2))]);
					}
					else if (funcInfo[0] == FLAG_SHOW)
					{
						movieClip.frameFunctions[frame].push([AnimationUtil.showChild, [movieClip].concat(funcInfo.slice(1, 2))]);
					}
					else if (funcInfo[0] == FLAG_HIDE)
					{
						movieClip.frameFunctions[frame].push([AnimationUtil.hideChild, [movieClip].concat(funcInfo.slice(1, 2))]);
					}
				}
				
				if (checkFrames.indexOf(frame) == -1)
				{
					checkFrames.push(frame);
				}
			}
		
			for each (var checkFrame:uint in checkFrames)
			{
				movieClip.addFrameScript(checkFrame - 1, function():void
				{
					AnimationUtil.checkFrame(movieClip);
				});
			}
		}
		
		/**
		 * 添加指定帧子对象的事件监听
		 * 
		 * @param movieClip 主影片剪辑
		 * @param frame 子对象所在帧
		 * @param childName 子对象名称
		 * @param listens 监听事件信息<BR />
		 *  　　 　　 [<BR />
		 *  　　 　　 　　[event1:String, callback1:Function],<BR />
		 *  　　 　　 　　[event2:String, callback2:Function],<BR />
		 *  　　 　　 　　...<BR />
		 *  　　 　　 ]<BR />
		 */		
		public static function listenChildEvent(movieClip:MovieClip, frame:uint, childName:String, listens:Array):void
		{
			if (!movieClip.hasOwnProperty('frameFunctions'))
			{			
				movieClip.frameFunctions = [];
			}
			
			if (!movieClip.frameFunctions[frame])
			{
				movieClip.frameFunctions[frame] = [];
			}
			
			movieClip.frameFunctions[frame].push([AnimationUtil.addChildListener, [movieClip, childName, listens]]);
			movieClip.addFrameScript(frame - 1, function():void
			{
				AnimationUtil.checkFrame(movieClip);
			});			
		}
		
		/**
		 * 添加指定帧上执行的方法（非覆盖性，同一帧可添加多个方法）
		 *  
		 * @param movieClip 源影片剪辑
		 * @param frame 目标帧数
		 * @param func 执行方法
		 * @param rest 方法参数
		 */			
		public static function addFrameScript(movieClip:MovieClip, frame:uint, func:Function, ... rest):void
		{
			if (!movieClip.hasOwnProperty('frameFunctions'))
			{			
				movieClip.frameFunctions = [];
			}
			
			if (!movieClip.frameFunctions[frame])
			{
				movieClip.frameFunctions[frame] = [];
			}
			
			if (rest.length > 0)
			{
				movieClip.frameFunctions[frame].push([func, rest]);
			}
			else
			{
				movieClip.frameFunctions[frame].push([func]);
			}			
			
			movieClip.addFrameScript(frame - 1, function():void
			{
				AnimationUtil.checkFrame(movieClip);
			});			
		}		
	}
}