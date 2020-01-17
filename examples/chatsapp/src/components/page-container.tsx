import { StyleSheet } from 'react-native'
import React, { useContext } from 'react'
import { AppContext } from './context';
import { Appbar } from 'react-native-paper'

const title = "Agora RTM QuickStart"


const Toolbar = (props: any) => (
  <Appbar.Header>
    <Appbar.Action icon="menu" />
    <Appbar.Content title={title} />
  </Appbar.Header>
)


const SubPageToolBar = (props: any) => {
  const ctx = useContext(AppContext)
  const onPress = () => {
    console.log("invoke leave")
    ctx.client.leave(ctx.channel).then(() => {
      console.log("leave success")
      ctx.client.logout().then(() => {
        // TODO: add logout code here.
      })
    }).catch(() => {
      // TODO: handle leave failure case.
      console.log("leave failured")
    })
    props.navigation.goBack()
  }

  return (
    <Appbar.Header>
      <Appbar.BackAction onPress={onPress} />
      <Appbar.Content title={`CHANNEL ${ctx.channel}`} />
    </Appbar.Header>
  )
}

const PageContainer = (children: any) => {

  const Comp = children

  const StackContainer = (_props: any) => {
    return (
      <Comp {..._props}></Comp>
    )
  }

  StackContainer.navigationOptions = (props: any) => ({
    header: (
      <>
        {
          props.navigation.state.routeName === "Home" ?
            <Toolbar /> :
            <SubPageToolBar {...props} />
        }
      </>
    ),
    ...(typeof Comp.navigationOptions === 'function'
      ? Comp.navigationOptions(props)
      : Comp.navigationOptions),
  })

  return StackContainer
}

export default PageContainer;