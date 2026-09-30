import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

interface CategoryCard { icon: string; title: string; count: string; color: string; }
interface CourseCard { title: string; category: string; instructor: string; duration: string; rating: string; image: string; }
interface AudienceContent { id: string; label: string; eyebrow: string; title: string; description: string; heroImage: string; heroImageAlt: string; heroCaptionTitle: string; heroCaptionSub: string; categories: CategoryCard[]; courses: CourseCard[]; }
interface ContactDetails { name: string; organization: string; email: string; phone: string; audience: string; message: string; }

@Component({
  selector: 'app-landing-v2',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './landing-v2.html',
  styleUrl: './landing-v2.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class LandingV2 {
  activeAudience = 'students';
  contactSubmitted = false;

  contact: ContactDetails = { name: '', organization: '', email: '', phone: '', audience: '', message: '' };

  readonly audiences: AudienceContent[] = [
    { id: 'students', label: 'For Students', eyebrow: 'Build your future', title: 'Learn skills that move you forward.', description: 'Build practical skills, earn certificates, and learn from expert-led courses designed for the real world.', heroImage: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1200&q=85', heroImageAlt: 'Students learning together', heroCaptionTitle: 'Learning in action', heroCaptionSub: 'Skills that create possibilities', categories: [
      { icon: '⌘', title: 'Technology', count: '120+ courses', color: 'blue' }, { icon: '◉', title: 'Data & AI', count: '64+ courses', color: 'purple' }, { icon: '✦', title: 'Design', count: '48+ courses', color: 'pink' }, { icon: '↗', title: 'Career Skills', count: '56+ courses', color: 'green' }, { icon: '◈', title: 'Business', count: '85+ courses', color: 'orange' }, { icon: '◎', title: 'Finance', count: '42+ courses', color: 'teal' }
    ], courses: [
      { title: 'Data Analytics with Real-World Projects', category: 'Data & AI', instructor: 'Priya Menon', duration: '6 weeks', rating: '4.8', image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=85' },
      { title: 'The Complete Guide to Modern Leadership', category: 'Leadership', instructor: 'LearnOS Academy', duration: '8 weeks', rating: '4.9', image: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=900&q=85' },
      { title: 'Digital Marketing Strategy Fundamentals', category: 'Business', instructor: 'Marcus Williams', duration: '5 weeks', rating: '4.7', image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&q=85' }
    ] },
    { id: 'businesses', label: 'For Businesses', eyebrow: 'Grow your people', title: 'Turn learning into business momentum.', description: 'Give your teams the skills, learning paths, and insights they need to perform at their best.', heroImage: 'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?auto=format&fit=crop&w=1200&q=85', heroImageAlt: 'Business team collaborating in a meeting', heroCaptionTitle: 'Teams in motion', heroCaptionSub: 'Skills that drive performance', categories: [
      { icon: '↗', title: 'Leadership', count: '36+ courses', color: 'green' }, { icon: '◈', title: 'Business Strategy', count: '72+ courses', color: 'orange' }, { icon: '⌘', title: 'Technology', count: '120+ courses', color: 'blue' }, { icon: '◎', title: 'Finance', count: '42+ courses', color: 'teal' }, { icon: '◉', title: 'Data & AI', count: '64+ courses', color: 'purple' }, { icon: '✦', title: 'Communication', count: '31+ courses', color: 'pink' }
    ], courses: [
      { title: 'Leadership for High-Performing Teams', category: 'Leadership', instructor: 'LearnOS Business Academy', duration: '4 weeks', rating: '4.9', image: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=900&q=85' },
      { title: 'Business Strategy and Competitive Advantage', category: 'Business Strategy', instructor: 'Daniel Carter', duration: '6 weeks', rating: '4.8', image: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=900&q=85' },
      { title: 'AI Readiness for Modern Organizations', category: 'Data & AI', instructor: 'Anika Sharma', duration: '5 weeks', rating: '4.9', image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=900&q=85' }
    ] },
    { id: 'universities', label: 'For Universities / Colleges', eyebrow: 'Extend your classroom', title: 'Make learning more connected.', description: 'Deliver engaging digital learning experiences for students, faculty, and academic partners.', heroImage: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=85', heroImageAlt: 'University students collaborating on campus', heroCaptionTitle: 'Learning without limits', heroCaptionSub: 'Extending the classroom', categories: [
      { icon: '⌘', title: 'Computer Science', count: '94+ courses', color: 'blue' }, { icon: '◉', title: 'Data Science', count: '58+ courses', color: 'purple' }, { icon: '✦', title: 'Design Studies', count: '41+ courses', color: 'pink' }, { icon: '◈', title: 'Management', count: '77+ courses', color: 'orange' }, { icon: '↗', title: 'Professional Skills', count: '52+ courses', color: 'green' }, { icon: '◎', title: 'Research', count: '28+ courses', color: 'teal' }
    ], courses: [
      { title: 'Applied Computer Science Foundations', category: 'Computer Science', instructor: 'LearnOS Academic', duration: '12 weeks', rating: '4.8', image: 'https://d2u1z1lopyfwlx.cloudfront.net/thumbnails/48a55c26-27e9-579d-81b2-e639c25a1145/f7e27c24-94c9-5d0a-9ce0-0dffa93b887f.jpg' },
      { title: 'Research Methods and Academic Writing', category: 'Research', instructor: 'Dr. Meera Rao', duration: '8 weeks', rating: '4.7', image: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=900&q=85' },
      { title: 'Innovation and Entrepreneurship', category: 'Management', instructor: 'Arjun Patel', duration: '6 weeks', rating: '4.8', image: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=900&q=85' }
    ] },
    { id: 'government', label: 'For Government', eyebrow: 'Develop communities', title: 'Create opportunity at scale.', description: 'Support workforce development with accessible, measurable, and career-focused learning.', heroImage: 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&w=1200&q=85', heroImageAlt: 'Public sector team in a government office', heroCaptionTitle: 'Serving with purpose', heroCaptionSub: 'Skills for public impact', categories: [
      { icon: '↗', title: 'Public Leadership', count: '38+ courses', color: 'green' }, { icon: '◈', title: 'Administration', count: '45+ courses', color: 'orange' }, { icon: '⌘', title: 'Digital Services', count: '67+ courses', color: 'blue' }, { icon: '◎', title: 'Finance & Policy', count: '39+ courses', color: 'teal' }, { icon: '◉', title: 'Data for Government', count: '29+ courses', color: 'purple' }, { icon: '✦', title: 'Citizen Services', count: '34+ courses', color: 'pink' }
    ], courses: [
      { title: 'Public Administration Essentials', category: 'Administration', instructor: 'LearnOS Public Sector Academy', duration: '8 weeks', rating: '4.9', image: 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&w=900&q=85' },
      { title: 'Digital Transformation in Public Services', category: 'Digital Services', instructor: 'Kavita Nair', duration: '6 weeks', rating: '4.8', image: 'https://d2u1z1lopyfwlx.cloudfront.net/thumbnails/4803603c-08f3-561b-baa3-b25b53f96134/e332ccbc-972c-522f-adda-71a26d059c15.jpg' },
      { title: 'Data-Informed Policy and Decision Making', category: 'Data for Government', instructor: 'Rohan Iyer', duration: '5 weeks', rating: '4.7', image: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?auto=format&fit=crop&w=900&q=85' }
    ] }
  ];

  setAudience(id: string): void { this.activeAudience = id; }
  get selectedAudience(): AudienceContent { return this.audiences.find(audience => audience.id === this.activeAudience) ?? this.audiences[0]; }
  get isStudentAudience(): boolean { return this.activeAudience === 'students'; }
  get audienceLoginParams(): { audience: string } { return { audience: this.activeAudience }; }

  openContact(event: MouseEvent): void {
    event.preventDefault();
    const formCard = document.getElementById('enquiry-form');
    const target = formCard ?? document.getElementById('contact');
    target?.scrollIntoView({ behavior: 'smooth', block: formCard ? 'center' : 'start' });
  }

  submitContact(): void { this.contactSubmitted = true; }
}