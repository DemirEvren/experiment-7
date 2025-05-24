import { Component, OnInit, Renderer2} from '@angular/core';
import { Router } from '@angular/router';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'frontend';
  url = environment.apiurl;


   //constructor genereated by ai, testing remove when done
  //no need to remove it because it fixed our issue
  constructor(private renderer: Renderer2, public router: Router // ✅ inject Router here
) {  // Inject Renderer2
    console.log(this.url);
  }

  //constructor(){
   // console.log(this.url);
  //}

  ngOnInit() {
    // Dynamically load external styles from S3
    this.loadExternalStyle("https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/styles.ec1660a3a6c2e5e8.css");
    this.loadExternalStyle("https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/app.component.css");
    this.setFavicon('https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/favicon.ico');
  }

  loadExternalStyle(url: string) {
    const link: HTMLLinkElement = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = url;
    document.head.appendChild(link);
  }

 setFavicon(url: string) {
    let link: HTMLLinkElement = document.querySelector("link[rel~='icon']") ||
      this.renderer.createElement('link');

    link.rel = 'icon';
    link.href = url;
    this.renderer.appendChild(document.head, link);
  }
  // ✅ Add this helper function to control carousel visibility
    showCarousel(): boolean {
    return this.router.url === '/home' || this.router.url === '' || this.router.url === '/add';
    }
}