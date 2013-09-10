package me.markezine.lazyloader.interfaces
{
	import me.markezine.lazyloader.core.LazyLoader;

	public interface ILazyLoaderPlugin
	{
		function init(instance:LazyLoader):void;
	}
}