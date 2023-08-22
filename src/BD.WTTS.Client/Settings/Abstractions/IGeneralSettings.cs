#nullable enable
#pragma warning disable IDE0079 // 请删除不必要的忽略
#pragma warning disable SA1634 // File header should show copyright
#pragma warning disable CS8601 // 引用类型赋值可能为 null。
#pragma warning disable CS0108 // 成员隐藏继承的成员；缺少关键字 new
//------------------------------------------------------------------------------
// <auto-generated>
//     此代码由包 BD.Common.Settings.V4.SourceGenerator.Tools 源生成。
//
//     对此文件的更改可能会导致不正确的行为，并且如果
//     重新生成代码，这些更改将会丢失。
// </auto-generated>
//------------------------------------------------------------------------------

// ReSharper disable once CheckNamespace
namespace BD.WTTS.Settings.Abstractions;

public partial interface IGeneralSettings
{
    static IGeneralSettings? Instance
        => Ioc.Get_Nullable<IOptionsMonitor<IGeneralSettings>>()?.CurrentValue;

    /// <summary>
    /// 自动检查应用更新
    /// </summary>
    bool? AutoCheckAppUpdate { get; set; }

    /// <summary>
    /// 自动检查应用更新的默认值
    /// </summary>
    const bool DefaultAutoCheckAppUpdate = true;

    /// <summary>
    /// 选择下载更新渠道
    /// </summary>
    UpdateChannelType? UpdateChannel { get; set; }

    /// <summary>
    /// 选择下载更新渠道的默认值
    /// </summary>
    const UpdateChannelType DefaultUpdateChannel = UpdateChannelType.Auto;

    /// <summary>
    /// 开机自启动
    /// </summary>
    bool? AutoRunOnStartup { get; set; }

    /// <summary>
    /// 开机自启动的默认值
    /// </summary>
    const bool DefaultAutoRunOnStartup = false;

    /// <summary>
    /// 启动时最小化
    /// </summary>
    bool? MinimizeOnStartup { get; set; }

    /// <summary>
    /// 启动时最小化的默认值
    /// </summary>
    const bool DefaultMinimizeOnStartup = false;

    /// <summary>
    /// 启用托盘图标
    /// </summary>
    bool? TrayIcon { get; set; }

    /// <summary>
    /// 启用托盘图标的默认值
    /// </summary>
    const bool DefaultTrayIcon = true;

    /// <summary>
    /// 游戏列表使用本地缓存
    /// </summary>
    bool? GameListUseLocalCache { get; set; }

    /// <summary>
    /// 游戏列表使用本地缓存的默认值
    /// </summary>
    const bool DefaultGameListUseLocalCache = false;

    /// <summary>
    /// 文本阅读器提供商，值为程序路径
    /// </summary>
    Dictionary<Platform, string>? TextReaderProvider { get; set; }

    /// <summary>
    /// 文本阅读器提供商，值为程序路径的默认值
    /// </summary>
    const Dictionary<Platform, string>? DefaultTextReaderProvider = null;

    /// <summary>
    /// Hosts 文件编码类型
    /// </summary>
    EncodingType? HostsFileEncodingType { get; set; }

    /// <summary>
    /// Hosts 文件编码类型的默认值
    /// </summary>
    const EncodingType DefaultHostsFileEncodingType = EncodingType.Auto;

    /// <summary>
    /// 是否使用硬件加速
    /// </summary>
    bool? GPU { get; set; }

    /// <summary>
    /// 是否使用硬件加速的默认值
    /// </summary>
    const bool DefaultGPU = true;

    /// <summary>
    /// 使用本机 OpenGL
    /// </summary>
    bool? NativeOpenGL { get; set; }

    /// <summary>
    /// 使用本机 OpenGL的默认值
    /// </summary>
    const bool DefaultNativeOpenGL = false;

    /// <summary>
    /// 屏幕捕获/允许截图，在一些含有机密的页面上是否允许截图，默认为 <see langword="false"/>
    /// </summary>
    bool? ScreenCapture { get; set; }

    /// <summary>
    /// 屏幕捕获/允许截图，在一些含有机密的页面上是否允许截图，默认为 <see langword="false"/>的默认值
    /// </summary>
    const bool DefaultScreenCapture = false;

    /// <summary>
    /// 禁用插件
    /// </summary>
    HashSet<string>? DisablePlugins { get; set; }

    /// <summary>
    /// 禁用插件的默认值
    /// </summary>
    const HashSet<string>? DefaultDisablePlugins = null;

    /// <summary>
    /// 插件安全模式
    /// </summary>
    bool? PluginSafeMode { get; set; }

    /// <summary>
    /// 插件安全模式的默认值
    /// </summary>
    const bool DefaultPluginSafeMode = true;

}
