package zTools.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * 字典工具类
	 *  
	 * @author Zivn
	 */	
	public class DictionaryUtil
	{		
		/**
		 * 获取字典的所有键名数组
		 *  
		 * @param d 源字典
		 */							
		public static function getKeys(d:Dictionary):Array
		{
			var a:Array = new Array();
			
			for (var key:Object in d)
			{
				a.push(key);
			}
			
			return a;
		}
		
		/**
		 * 获取字典的所有值数组
		 *  
		 * @param d 源字典
		 */					
		public static function getValues(d:Dictionary):Array
		{
			var a:Array = new Array();
			
			for each (var value:Object in d)
			{
				a.push(value);
			}
			
			return a;
		}		
	}
}