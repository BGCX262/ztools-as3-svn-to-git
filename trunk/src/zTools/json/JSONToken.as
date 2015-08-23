package zTools.json 
{
	/**
	 * JSON 解释标记
	 * 
	 * @author Zivn
	 */
	public class JSONToken 
	{	
		private var _type:int;
		private var _value:Object;
		
		/**
		 * 创建指定类型和值的 JSON 解释标记
		 *
		 * @param type 标记类型
		 * @param value 标记值
		 */
		public function JSONToken(type:int = -1, value:Object = null ) 
		{
			_type = type;
			_value = value;
		}
		
		/**
		 * 获取标记类型
		 *
		 */
		public function get type():int 
		{
			return _type;	
		}
		
		/**
		 * 设置标记类型
		 *
		 * @param type 标记类型
		 */
		public function set type(value:int):void 
		{
			_type = value;	
		}
		
		/**
		 * 获取标记值
		 *
		 */
		public function get value():Object 
		{
			return _value;	
		}
		
		/**
		 * 设置标记值
		 *
		 * @param value 标记值
		 */
		public function set value (v:Object):void 
		{
			_value = v;	
		}
	}	
}