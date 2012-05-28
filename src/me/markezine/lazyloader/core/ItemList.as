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
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;

	internal class ItemList
	{
		private var xml:XML;
		private var items:Dictionary;
		
		public function ItemList(){
			XML.prettyIndent = 2;
			XML.prettyPrinting = true;
			xml = new XML(<list/>);
			items = new Dictionary();
		}
		
		public function addItem(item:LazyLoaderItem):String{
			var uniqueid:String = LazyLoaderUtils.createUniqueId();
			while(items[uniqueid] != null) uniqueid = LazyLoaderUtils.createUniqueId();
			var node:XML = new XML(<item/>);
			if(item.instance != "default") node.@instanceId = item.instance;
			
			node.@url = item.url;
			node.@absoluteURL = item.absoluteUrl;
			node.@type = item.type;
			node.setChildren(uniqueid);
			for(var i:String in item.params){
				node.@[i] = item.params[i];
			};
			
			xml.appendChild(node);
			items[uniqueid] = item;
			return uniqueid;
		}
		
		public function getItem(parameters:Object, instance:String = null, type:String = null):LazyLoaderItem{
			if(parameters is String && items[parameters]){
				return items[parameters];
			}
			return null;
			
			var filteredList:XMLList = xml..item;
			
			if(instance) filteredList = filteredList.(@instanceId == instance);
			if(type) filteredList = filteredList.(@type == type);
			
			if(parameters is String){
				return getItem(String(filteredList.(@id == parameters || @url == parameters || @absoluteURL == parameters)[0]));
			}
			
			for(var i:String in parameters){
				filteredList = filteredList.(attribute(i) == parameters[i]);
			}
			
			return getItem(String(filteredList[0]));
		}
		
		
		public function destroyItem(uniqueid:String):void{
			var item:LazyLoaderItem = items[uniqueid];
			item.destroy();
			delete items[uniqueid];
			while(xml.item.(text() == uniqueid).length() > 0){
				delete xml.item.(text() == uniqueid)[0];
			}
		}
		
		public function destroyInstance(instanceid:String):void{
			while(xml.item.(@instanceId == instanceid).length() > 0){
				destroyItem(xml.item.(@instanceId == instanceid));
			}
		}
	}
}