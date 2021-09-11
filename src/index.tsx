import React from 'react';
import {
  Platform,
  requireNativeComponent,
  UIManager,
  findNodeHandle,
  Image,
  ImageRequireSource,
} from 'react-native';

const NativeRefreshControl = requireNativeComponent('LyRefreshControlView');

interface RefreshControlProps {
  idleSources: ImageRequireSource[];
  refreshingSources: ImageRequireSource[];
  refreshing: boolean;
  tintColor?: string;
  titleColor?: string;
  title?: string;
  enabled?: boolean;
  onRefresh?: () => void | Promise<void>;
}

export default class LYRefreshControl extends React.Component<RefreshControlProps> {
  _nativeRef: any;
  _lastNativeRefreshing = false;

  componentDidMount() {
    this._lastNativeRefreshing = this.props.refreshing;
  }

  componentDidUpdate(prevProps: RefreshControlProps) {
    if (this.props.refreshing !== prevProps.refreshing) {
      this._lastNativeRefreshing = this.props.refreshing;
    } else if (
      this.props.refreshing !== this._lastNativeRefreshing &&
      this._nativeRef
    ) {
      UIManager.dispatchViewManagerCommand(
        this._getViewHandle(),
        this._getCommands().setNativeRefreshing,
        [this.props.refreshing]
      );
      this._lastNativeRefreshing = this.props.refreshing;
    }
  }

  render() {
    if (Platform.OS === 'ios') {
      const { idleSources, refreshingSources, ...props } = this.props;
      const resolveIdleSources = idleSources.map((source) => {
        return (
          Image.resolveAssetSource(source) || {
            uri: undefined,
            width: undefined,
            height: undefined,
          }
        );
      });

      const resolveRefreshingSources = refreshingSources.map((source) => {
        return (
          Image.resolveAssetSource(source) || {
            uri: undefined,
            width: undefined,
            height: undefined,
          }
        );
      });

      return (
        <NativeRefreshControl
          {...props}
          ref={this._setNativeRef}
          // @ts-ignore
          onRefresh={this._onRefresh}
          idleSources={resolveIdleSources}
          refreshingSources={resolveRefreshingSources}
        />
      );
    } else {
      return null;
    }
  }

  _onRefresh = () => {
    this._lastNativeRefreshing = true;
    this.props.onRefresh && this.props.onRefresh();
    this.forceUpdate();
  };

  _setNativeRef = (ref: any) => {
    this._nativeRef = ref;
  };

  // @ts-ignore
  _getCommands = () => UIManager.LyRefreshControlView.Commands;

  _getViewHandle = () => {
    return findNodeHandle(this._nativeRef);
  };
}
