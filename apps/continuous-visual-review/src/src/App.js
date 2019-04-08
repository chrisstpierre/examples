import React, { PureComponent } from 'react';

import ListPages from './ListPages'
import Page from './Page'
import './App.css'


class App extends PureComponent {

  // handle the current page displayed on screen; or the list if null
  state = { currentPage: null }
  focusPage = (currentPage) => { this.setState({ currentPage }) }
  displayList = () => { this.setState({ currentPage: null }) }

  renderPage() {
    const { currentPage } = this.state

    return (
      <Page
        displayList={this.displayList}
        {...currentPage}
        />
    )
  }

  render() {
    return (
      <div className="app">
        <h1>CI Page Diff</h1>
        {this.state.currentPage
          ? this.renderPage()
          : <ListPages focusPage={this.focusPage} {...window.DATA_CI} />}
      </div>
    );
  }
}

export default App;
