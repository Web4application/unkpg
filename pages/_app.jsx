import { FormspreeProvider } from '@formspree/react';
function App({ Component, pageProps }) {
  return (
  	<FormspreeProvider project="{your-project-id}">
      <Component {...pageProps} />
    </FormspreeProvider>
  );
}
export default App;
