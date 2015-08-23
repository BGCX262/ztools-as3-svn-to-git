package zTools.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	
	/**
	 * 资源加载项目
	 * 
	 * @author Zivn
	 */
	public class LoaderItem
	{		
		/**
		 * 最大重试次数 
		 */		
		public static const MAX_RETRY_TIMES:uint = 3;
		
		/**
		 * 项目类型：文本 
		 */		
		public static const TYPE_TEXT:uint = 0;
		/**
		 * 项目类型：XML
		 */		
		public static const TYPE_XML:uint = 1;
		/**
		 * 项目类型：可视化对象（SWF、GIF、JPG）
		 */		
		public static const TYPE_LOADER:uint = 2;
		
		/**
		 * 项目状态：初始状态 
		 */		
		public static const STATUS_INIT:uint = 0;
		/**
		 * 项目状态：加载中
		 */		
		public static const STATUS_LOADDING:uint = 1;
		/**
		 * 项目状态：加载成功
		 */				
		public static const STATUS_SUCCESSED:uint = 2;
		/**
		 * 项目状态：加载失败
		 */		
		public static const STATUS_FAILED:uint = 3;
		
		/**
		 * 链接地址 
		 */		
		private var _url:String;
		/**
		 * 项目类型 
		 */		
		private var _type:uint;
		/**
		 *  项目大小
		 */
		private var _size:uint;
		/**
		 * 加载百分比
		 */		
		private var _percent:Number;
		/**
		 * 项目状态 
		 */		
		private var _status:uint;
		/**
		 * 已加载资源 
		 */		
		private var _resource:Object;
		/**
		 * 重试次数 
		 */		
		private var _retryTimes:uint;
		
		/**
		 * 初始化资源加载项目
		 *  
		 * @param url
		 * @param type
		 */		
		public function LoaderItem(url:String, size:uint, type:uint = TYPE_TEXT)
		{
			_url = url;
			_type = ([TYPE_TEXT, TYPE_XML, TYPE_LOADER].indexOf(type) == -1) ? TYPE_TEXT:type;
			_size = size;
			_percent = 0;
			_status = STATUS_INIT;
			_resource = null;
			_retryTimes = 0;
		}

		/**
		 * 获取链接地址
		 * 
		 */		
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * 获取项目类型
		 * 
		 */
		public function get type():uint
		{
			return _type;
		}
		
		/**
		 * 项目大小 
		 */
		public function get size():uint
		{
			return _size;
		}
		
		/**
		 * 获取加载百分比
		 * 
		 */		
		public function get percent():Number
		{
			return _percent;
		}
		
		/**
		 * 获取项目状态
		 * 
		 */
		public function get status():uint
		{
			return _status;
		}

		/**
		 * 获取重试次数
		 * 
		 */		
		public function get retryTimes():uint
		{
			return _retryTimes;
		}

		/**
		 * 获取已加载资源
		 * 
		 */		
		public function get resource():Object
		{
			return _resource;
		}
		
		/**
		 * 开始加载资源
		 *  
		 */		
		internal function load():Boolean
		{
			if (_status == STATUS_INIT)
			{
				_status = STATUS_LOADDING;
				return true;
			}
			else
			{
				return false;				
			}				
		}
		
		/**
		 * 开始加载资源
		 *  
		 */		
		internal function loading(loadBytes:uint):Boolean
		{
			if (_status == STATUS_LOADDING)
			{
				_percent = Math.min(100, Math.max(0, uint(loadBytes * 10000 / _size) / 100));
				return true;
			}
			else
			{
				return false;				
			}
		}
		
		/**
		 * 加载错误后重试
		 * 
		 */		
		internal function retry():Boolean
		{
			_retryTimes += 1;
			
			if (_retryTimes >= MAX_RETRY_TIMES)
			{
				_status = STATUS_FAILED;
				return false;
			}
			else
			{
				_status = STATUS_INIT;
				_percent = 0;
				return true;
			}
		}
		
		/**
		 * 资源加载完成
		 *  
		 * @param loader
		 */		
		internal function finish(loader:Object):void
		{
			if (_type == TYPE_TEXT)
			{
				_resource = new String(loader.data); 
			}
			else if (_type == TYPE_XML)
			{
				_resource = new XML(loader.data); 
			}
			else
			{
				_resource = loader.loader as Loader; 
			}
			
			_status = STATUS_SUCCESSED;
			_percent = 100;
		}
		
		/**
		 * 从已加载资源的库中获取影片剪辑定义的实例 
		 * 
		 * @param className
		 */		
		public function getClip(className:String):MovieClip
		{
			if (_resource.hasOwnProperty('contentLoaderInfo') && 
				_resource.contentLoaderInfo.applicationDomain.hasDefinition(className))
			{
				var movieClass:Class = _resource.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
				return new movieClass() as MovieClip;
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 从已加载资源的库中获取位图定义的实例 
		 * 
		 * @param className
		 */		
		public function getPic(className:String):Bitmap
		{
			if (_resource.hasOwnProperty('contentLoaderInfo') && 
				_resource.contentLoaderInfo.applicationDomain.hasDefinition(className))
			{
				var picClass:Class = _resource.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
				var picData:BitmapData = new picClass(0, 0) as BitmapData;	
				return picData ? (new Bitmap(picData)) : null;	
			}
			else
			{
				return null;
			}
		}
	}
}