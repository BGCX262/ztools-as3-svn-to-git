package zTools.loader
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * 资源加载器
	 * 
	 * @author Zivn
	 */	
	public class ResLoader extends Sprite
	{
		/**
		 * 资源加载器静态实例（用于实现单例模式）
		 * 
		 */		
		private static var _instance:ResLoader = new ResLoader();
		
		/**
		 * 所有加载项目（以URL为索引的字典） 
		 * 
		 */		
		private var _itemDict:Dictionary;
		/**
		 * 待加载URL列表 
		 * 
		 */		
		private var _urlQuery:Array;
		/**
		 * 当前加载的URL 
		 * 
		 */		
		private var _currentUrl:String;
		/**
		 * 加载资源的总大小 
		 * 
		 */		
		private var _totalBytes:uint;
		/**
		 * 已加载资源大小
		 * 
		 */		
		private var _loadBytes:uint;
		/**
		 * 当前加载项目的已加载大小
		 * 
		 */		
		private var _currentBytes:uint;
		
		/**
		 * 初始化资源加载器 
		 * 
		 */		
		public function ResLoader()
		{
			if (_instance) 
			{  
				throw new Error("Please use ResLoader.instance");  
			} 
			
			_itemDict = new Dictionary();
			_urlQuery = new Array();
		}
		
		/**
		 * 获得资源加载器实例
		 * 
		 */		
		static public function getInstance():ResLoader
		{			
			return _instance;
		}
		
		/**
		 * 添加加载项目
		 *  
		 * @param item
		 */		
		public function addItem(item:LoaderItem):void
		{		
			if (!_itemDict[item.url])
			{
				_itemDict[item.url] = item;
				_totalBytes += item.size;
			}
			
			_urlQuery.push(item.url);
		}
		
		/**
		 * 获取加载项目
		 *  
		 * @param url
		 */		
		public function getItem(url:String):LoaderItem
		{
            var index:Number = this._urlQuery.indexOf(url);
            
            if (index != -1)
            {
                _urlQuery.splice(index, 1);
                _urlQuery.unshift(url);
            }
            
			return _itemDict[url];
		}
		
		/**
		 * 获取加载百分比
		 * 
		 */		
		public function getPercent():Number
		{
			return Math.min(100, Math.max(0, uint((_loadBytes + _currentBytes) * 10000 / _totalBytes) / 100));
		}
		
		/**
		 * 开始加载所有待加载项目 
		 * 
		 */		
		public function load():void
		{
			if (!_currentUrl && _urlQuery)
			{
				var item:LoaderItem;
				
				while (_urlQuery.length > 0)
				{				
					item = _itemDict[_urlQuery.shift()];
					
					if (item.load())
					{
						_currentUrl = item.url;
						_currentBytes = 0;
						break;
					}
					else if (item.status == LoaderItem.STATUS_SUCCESSED)
					{
						dispatchEvent(new LoaderEvent(LoaderEvent.SUCCESS, _itemDict, item));
					}
					else if (item.status == LoaderItem.STATUS_FAILED)
					{
						dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, _itemDict, item));
					}
				}
				
				if (_currentUrl)
				{
					var request:URLRequest = new URLRequest(_currentUrl);
					var loader:Object;
					
					if (item.type == LoaderItem.TYPE_TEXT || item.type == LoaderItem.TYPE_XML)
					{
						loader = new URLLoader();		
						
						loader.addEventListener(Event.COMPLETE, completeHandler);
						loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
						loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
						loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
						
						loader.load(request);
					} 
					else 
					{
						loader = new Loader();
						
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
						loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
						loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
						
						loader.load(request);
					}
				}
				else
				{
					dispatchEvent(new LoaderEvent(LoaderEvent.FINISH, _itemDict, item));
				}
			}
		}
		
		/**
		 * 加载完成句柄
		 *  
		 * @param event
		 */		
		private function completeHandler(event:Event):void
		{						
			var item:LoaderItem = _itemDict[_currentUrl];
			item.finish(event.target);
			
			_loadBytes += item.size;
			_currentUrl = null;	
			_currentBytes = 0;
			
			dispatchEvent(new LoaderEvent(LoaderEvent.SUCCESS, _itemDict, item));
			
			if (_urlQuery.length > 0)
			{
				load();
			} 
			else
			{
				dispatchEvent(new LoaderEvent(LoaderEvent.FINISH, _itemDict, item));
			}
		}
		
		/**
		 * 正在加载句柄
		 *  
		 * @param event
		 */	
		private function progressHandler(event:ProgressEvent):void
		{
			_currentBytes = event.bytesLoaded;
			
			var item:LoaderItem = _itemDict[_currentUrl];
			
			if (item.loading(event.bytesLoaded))
			{
				dispatchEvent(new LoaderEvent(LoaderEvent.LOADING, _itemDict, item));
			}
		}
		
		/**
		 * 加载失败句柄
		 *  
		 * @param event
		 */	
		private function errorHandler(event:ErrorEvent):void
		{		
			var item:LoaderItem = _itemDict[_currentUrl];
			
			_currentUrl = null;
			_currentBytes = 0;
			
			if (item.retry())
			{
				_urlQuery.push(_currentUrl);
				load();
			}
			else
			{
				dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, _itemDict, item));
			}
		}
	}
}
