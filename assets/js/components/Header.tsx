import * as React from 'react';

const Header: React.FC = () => (
  <header>
    <section className="container">
      <nav role="navigation">
        <ul>
          <li>
            <a className="new_link" href="/">Home</a>
          </li>
          <li>
            <a className="new_link" href="/statistics">Statistics</a>
          </li>
        </ul>
      </nav>
      <a href="/" className="phx-logo">
        <img src="/images/phoenix.png" alt="Phoenix Framework Logo" />
      </a>
    </section>
  </header>
);

export default Header;
