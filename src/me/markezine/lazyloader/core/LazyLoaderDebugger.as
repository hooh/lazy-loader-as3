package me.markezine.lazyloader.core
{
	internal class LazyLoaderDebugger
	{
		static internal function debug(loader:LazyLoader, type:String, item:LazyLoaderItem):void{
			if(!loader && LazyLoader.debugMode.indexOf(type) == -1){
				return;
			}else if(loader && loader.debugMode.indexOf(type) == -1){
				return;
			} 
			trace("LazyLoader action: ", type, item.url);
		}
	}
}