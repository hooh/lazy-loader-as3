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