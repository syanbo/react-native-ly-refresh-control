import React, { useEffect, useState } from 'react';
import { StyleSheet, View, ScrollView, SafeAreaView } from 'react-native';
import LYRefreshControl from 'react-native-ly-refresh-control';

export default function App() {
  const [refreshing, setRefreshing] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setRefreshing(false);
    }, 3000);
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
    }, 3000);
    console.log('下拉刷新');
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scroll}
        refreshControl={
          <LYRefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            idleSources={[
              require('./assets/dropdown_anim__0001.png'),
              require('./assets/dropdown_anim__0002.png'),
              require('./assets/dropdown_anim__0003.png'),
              require('./assets/dropdown_anim__00020.png'),
              require('./assets/dropdown_anim__00021.png'),
              require('./assets/dropdown_anim__00030.png'),
              require('./assets/dropdown_anim__00031.png'),
            ]}
            refreshingSources={[
              require('./assets/dropdown_loading_01.png'),
              require('./assets/dropdown_loading_02.png'),
              require('./assets/dropdown_loading_03.png'),
            ]}
          />
        }
      >
        {[...new Array(10)].map((_v: any, i) => (
          <View key={i} style={styles.cell} />
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scroll: {
    flex: 1,
  },
  cell: {
    height: 44,
    backgroundColor: 'red',
    margin: 4,
  },
});
