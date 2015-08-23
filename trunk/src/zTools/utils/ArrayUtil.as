package zTools.utils
{
	/**
	 * 数组工具类
	 *  
	 * @author Zivn
	 */	
	public class ArrayUtil
	{
		/**
		 * 判断数组中是否含有指定值 
		 * 
		 * @param arr 源数组
		 * @param value 指定值
		 */					
		public static function hasValue(arr:Array, value:Object):Boolean
		{
			return (arr.indexOf(value) != -1);
		}	
		
		/**
		 * 移除数组中的指定值 
		 * 
		 * @param arr 源数组
		 * @param value 指定值
		 */	
		public static function removeValue(arr:Array, value:Object):void
		{
			var len:uint = arr.length;
			
			for(var i:Number = len; i >= 0; i--)
			{
				if (arr[i] === value)
				{
					arr.splice(i, 1);
				}
			}					
		}

		/**
		 * 获得一个浅复制的元素不重复的拷贝
		 *  
		 * @param arr 源数组
		 */		
		public static function uniqueCopy(a:Array):Array
		{
			var newArray:Array = new Array();
			
			var len:Number = a.length;
			var item:Object;
			
			for (var i:uint = 0; i < len; ++i)
			{
				item = a[i];
				
				if (ArrayUtil.hasValue(newArray, item))
				{
					continue;
				}
				
				newArray.push(item);
			}
			
			return newArray;
		}
		
		/**
		 * 获得一个浅复制的拷贝
		 *  
		 * @param arr 源数组
		 */		
		public static function copyArray(arr:Array):Array
		{	
			return arr.slice();
		}
		
		/**
		 * 判断2个数组内容是否一致
		 *  
		 * @param arr1 数组1
		 * @param arr2 数组2
		 */		
		public static function isEqual(arr1:Array, arr2:Array):Boolean
		{
			if(arr1.length != arr2.length)
			{
				return false;
			}
			
			var len:Number = arr1.length;
			
			for(var i:Number = 0; i < len; i++)
			{
				if(arr1[i] !== arr2[i])
				{
					return false;
				}
			}
			
			return true;
		}
	}
}
