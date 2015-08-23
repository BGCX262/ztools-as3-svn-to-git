package zTools.crypto
{
	import zTools.utils.IntUtil;
	import flash.utils.ByteArray;
	
	/**
	 *  SHA1哈希工具类
	 *
	 */
	public class SHA1
	{
		public static var digest:ByteArray;
		
		/**
		 * 在源字符串上执行SHA1哈希算法
		 * 
		 * @param s 源字符串
		 */
		public static function hash(s:String):String
		{
			var blocks:Array = createBlocksFromString(s);
			var byteArray:ByteArray = hashBlocks(blocks);
			
			return IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true);
		}
		
		/**
		 * 在源二进制数组上执行SHA1哈希算法
		 *
		 * @param s 源二进制数组
		 */
		public static function hashBytes(data:ByteArray):String
		{
			var blocks:Array = SHA1.createBlocksFromByteArray(data);
			var byteArray:ByteArray = hashBlocks(blocks);
			
			return IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true)
					+ IntUtil.toHex(byteArray.readInt(), true);
		}
		
		private static function hashBlocks(blocks:Array):ByteArray
		{
			var h0:int = 0x67452301;
			var h1:int = 0xefcdab89;
			var h2:int = 0x98badcfe;
			var h3:int = 0x10325476;
			var h4:int = 0xc3d2e1f0;
			
			var len:int = blocks.length;
			var w:Array = new Array(80);
			var temp:int;
			
			for (var i:int = 0; i < len; i += 16) 
			{
				var a:int = h0;
				var b:int = h1;
				var c:int = h2;
				var d:int = h3;
				var e:int = h4;				
				var t:int;
				
				for (t = 0; t < 20; t++) 
				{					
					if (t < 16) 
					{
						w[t] = blocks[i + t];
					} 
					else 
					{
						temp = w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16];
						w[t] = (temp << 1) | (temp >>> 31)
					}

					temp = ((a << 5) | (a >>> 27)) + ((b & c) | (~b & d)) + e + int(w[t]) + 0x5a827999;

					e = d;
					d = c;
					c = (b << 30) | (b >>> 2);
					b = a;
					a = temp;
				}
				
				for (; t < 40; t++)
				{
					temp = w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16];
					w[t] = (temp << 1) | (temp >>> 31);
					temp = ((a << 5) | (a >>> 27)) + (b ^ c ^ d) + e + int(w[t]) + 0x6ed9eba1;

					e = d;
					d = c;
					c = (b << 30) | (b >>> 2);
					b = a;
					a = temp;
				}
				
				for (; t < 60; t++)
				{
					temp = w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16];
					w[t] = (temp << 1) | (temp >>> 31);
					temp = ((a << 5) | (a >>> 27)) + ((b & c) | (b & d) | (c & d)) + e + int(w[t]) + 0x8f1bbcdc;
					
					e = d;
					d = c;
					c = (b << 30) | (b >>> 2);
					b = a;
					a = temp;
				}
				
				for (; t < 80; t++)
				{
					temp = w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16];
					w[t] = (temp << 1) | (temp >>> 31);
					temp = ((a << 5) | (a >>> 27)) + (b ^ c ^ d) + e + int(w[t]) + 0xca62c1d6;

					e = d;
					d = c;
					c = (b << 30) | (b >>> 2);
					b = a;
					a = temp;
				}
				
				h0 += a;
				h1 += b;
				h2 += c;
				h3 += d;
				h4 += e;		
			}
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeInt(h0);
			byteArray.writeInt(h1);
			byteArray.writeInt(h2);
			byteArray.writeInt(h3);
			byteArray.writeInt(h4);
			byteArray.position = 0;
			
			digest = new ByteArray();
			digest.writeBytes(byteArray);
			digest.position = 0;
			return byteArray;
		}

		private static function createBlocksFromByteArray(data:ByteArray):Array
		{
			var oldPosition:int = data.position;
			data.position = 0;
			
			var blocks:Array = new Array();
			var len:int = data.length * 8;
			var mask:int = 0xFF;

			for(var i:int = 0; i < len; i += 8)
			{
				blocks[i >> 5] |= (data.readByte() & mask) << (24 - i % 32);
			}
			
			blocks[len >> 5] |= 0x80 << (24 - len % 32);
			blocks[(((len + 64) >> 9) << 4) + 15] = len;
			
			data.position = oldPosition;
			
			return blocks;
		}

		private static function createBlocksFromString(s:String):Array
		{
			var blocks:Array = new Array();
			var len:int = s.length * 8;
			var mask:int = 0xFF;

			for(var i:int = 0; i < len; i += 8) 
			{
				blocks[i >> 5] |= (s.charCodeAt(i / 8) & mask) << (24 - i % 32);
			}
			
			blocks[len >> 5] |= 0x80 << (24 - len % 32);
			blocks[(((len + 64) >> 9) << 4) + 15] = len;
			return blocks;
		}
		
	}
}
