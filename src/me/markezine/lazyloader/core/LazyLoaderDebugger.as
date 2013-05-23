package me.markezine.lazyloader.core
{
	import flash.external.ExternalInterface;

	internal class LazyLoaderDebugger
	{	
		static internal function debug(loader:LazyLoader, type:String, item:LazyLoaderItem, additionalInfo:Object=null):void{
			if(!loader && LazyLoader.debugMode.indexOf(type) == -1){
				return;
			}else if(loader && loader.debugMode.indexOf(type) == -1){
				return;
			} 
			
			
			var debugString:String;
			
			switch(type){
				case LazyLoaderDebugModes.ADD:
					debugString = "LazyLoader action: " + type + " " + item.url;
					break;
				
				case LazyLoaderDebugModes.ERRORS:
					debugString = "LazyLoader action: " + "error " + "relative: " + (item ? item.url : "no item") + " absolute: " + 
						(item ? item.absoluteUrl : "no item") + " errorType: " + additionalInfo;
					break;
			}
			
			trace(debugString);
			if(LazyLoader.debugOnJavascriptConsole && ExternalInterface && ExternalInterface.available) ExternalInterface.call("console.log", debugString);  

		}
	}
}