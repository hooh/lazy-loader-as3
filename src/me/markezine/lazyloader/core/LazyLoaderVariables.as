/**
 * Licensed under the MIT License and Creative Commons 3.0 BY-SA
 * 
 * Copyright (c) 2011 The LazyLoader Team
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE COMMONS PUBLIC 
 * LICENSE ("CCPL" OR "LICENSE"). THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. 
 * ANY USE OF THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
 * PROHIBITED.
 * BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO BE BOUND BY THE 
 * TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE MAY BE CONSIDERED TO BE A CONTRACT, THE 
 * LICENSOR GRANTS YOU THE RIGHTS CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH 
 * TERMS AND CONDITIONS.
 * 
 * http://creativecommons.org/licenses/by-sa/3.0/legalcode
 *  
 * http://code.google.com/p/lazy-loader-as3
 * 
 * @author João Paulo Marquesini (markezine)
 * 
 */
package me.markezine.lazyloader.core
{
	/**
	 * The LazyLoaderVariables class can be used to create the parameters object keeping the 
	 * auto complete for the default parameters.
	 * 
	 */
	public dynamic class LazyLoaderVariables
	{
		/**
		 * The type of the file. If you omit this value, LazyLoader will try to identify it based 
		 * on the file extension.
		 */
		public var type:String;
		/**
		 * The id the item should be associated with. 
		 */
		public var id:String;
		/**
		 * The LoaderContext or SoundLoaderContext that should be used.
		 */
		public var context:Object; 
		
		/**
		 * Used to define the parameters object of an item.
		 * You can add dynamic parameters for searching in this class too. 
		 * @param id The id the item should be associated with. 
		 * @param context the LoaderContext that should be used.
		 * @param type The type of the file. If you omit this value, LazyLoader will try to identify
		 * it based on the file extension.
		 */
		public function LazyLoaderVariables(id:String = null, context:Object = null, type:String = null)
		{
			this.id = id;
			this.context = context;
			this.type = type;
		}
		
		internal function get forceType():String{
			return type;
		}
		
		internal function toObject():Object{
			var result:Object = {};
			for(var i:String in this){
				result[i] = this[i];
			}
			
			result.id = this.id;
			result.context = this.context;
			result.type = this.type;
			result.forceType = this.type;
			
			return result;
		}
	}
}