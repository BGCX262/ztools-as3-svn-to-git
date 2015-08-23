package zTools.loader
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * 资源加载器事件
	 *  
	 * @author Zivn
	 */	
	public class LoaderEvent extends Event
	{
		/**
		 * 事件类型：成功加载资源
		 * 
		 */		
		public static const SUCCESS:String = 'ResLoader_OneSuccess';	
		/**
		 * 事件类型：资源加载失败
		 * 
		 */		
		public static const FAIL:String = 'ResLoader_OneFail';
		/**
		 * 事件类型：资源加载中
		 * 
		 */		
		public static const LOADING:String = 'ResLoader_OneLoading';	
		/**
		 * 事件类型：所有资源加载完毕
		 * 
		 */		
		public static const FINISH:String = 'ResLoader_AllComplete';		
		
		/**
		 * 所有资源（以URL为索引的字典）
		 *  
		 */		
		private var _items:Dictionary;	
		/**
		 * 当前资源
		 * 
		 */		
		private var _item:LoaderItem;
		
		/**
		 * 初始化资源加载器事件
		 *  
		 * @param type
		 * @param items
		 * @param item
		 */		
		public function LoaderEvent(type:String, items:Dictionary, item:LoaderItem = null):void
		{
			super(type);
			
			_items = items;
			_item = item;
		}
		
		/**
		 * 获取所有资源
		 * 
		 */		
		public function get items():Dictionary
		{
			return _items;
		}
		
		/**
		 * 获取当前资源
		 * 
		 */		
		public function get item():LoaderItem
		{
			return _item;
		}
	}
}