package zTools.json 
{
	/**
	 * JSON 解释错误类
	 * 
	 * @author Zivn
	 */
	public class JSONParseError extends Error 	
	{	
		private var _location:int;		
		private var _text:String;
	
		/**
		 * 初始化 JSON 解释错误
		 *
		 * @param message 错误信息
		 * @param location 引发错误的位置
		 * @param text 引发错误的字符串
		 */
		public function JSONParseError(message:String = "", location:int = 0, text:String = "") 
		{
			super(message);
			
			name = "JSONParseError";
			_location = location;
			_text = text;
		}

		/**
		 * 发生解析错误的位置（只读）
		 * 
		 */
		public function get location():int 
		{
			return _location;
		}
		
		/**
		 * 发生解析错误的字符串（只读）
		 * 
		 */
		public function get text():String 
		{
			return _text;
		}
	}
	
}