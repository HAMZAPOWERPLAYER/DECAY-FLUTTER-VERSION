import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/controls.dart';
import '../components/page.dart';
import '../theme.dart';

/// Static content pages — ported from `src/app/settings/*.tsx`.

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuietPage(
      title: 'How it works',
      subtitle: 'A small explanation, without giving everything away.',
      children: [
        Prose(children: [
          SectionHeading('Presence'),
          P('A visit counts when you stay with your companion for about twelve '
              'seconds. Opening the app and passing through is not the same as '
              'being there.'),
          SectionHeading('Fading'),
          P('Time away increases its neglect. Each real visit eases some of that '
              'neglect, but it does not erase the past or return the companion '
              'to its beginning.'),
          SectionHeading('Impermanence'),
          P('Care can slow the ending, but nothing here lives forever. A longer '
              'life is possible through returning, never guaranteed through it.'),
          SectionHeading('Passing'),
          P('When the companion reaches its final stage, it passes quietly. The '
              'app creates a Death Certificate from the life you shared: its '
              'lifespan, its cause, its eulogy, and the moment it was noticed.'),
          SectionHeading('Privacy'),
          P('Decay is offline-first. Your companion and its visits stay on this '
              'device. There is no account, score, or leaderboard.'),
        ]),
      ],
    );
  }
}

const String _updated = 'September 2026';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuietPage(
      title: 'Terms and conditions',
      subtitle: 'last updated $_updated',
      children: const [
        Prose(children: [
          SectionHeading('What Decay is'),
          P('Decay is an art piece about impermanence. It is provided as-is, for '
              'reflection, entertainment and emotional experience. It is not a '
              'mental-health tool, not a therapy, and not a substitute for '
              'speaking to someone who can help.'),
          SectionHeading('The mechanic is deliberately irreversible'),
          P('The companion in Decay fades when it is neglected and eventually '
              'passes. When it passes, it does not return. There is no restart '
              'button, no restore, and no way to recover a past life. This is '
              'the entire point of the work, and it was disclosed to you before '
              'you planted it.'),
          P('Because everything Decay remembers lives only on your own device, '
              'uninstalling the app or clearing its storage erases that history '
              'permanently. No copy exists anywhere else, and none can be '
              'requested. The only way to begin again is to install the app '
              'anew and plant a new companion.'),
          SectionHeading('Your data'),
          P('Decay collects nothing. It has no account system, no servers, and '
              'makes no network requests. Your visit history exists only in '
              'local storage on your device. The Privacy Policy describes this '
              'in full.'),
          SectionHeading('No warranty'),
          P('Decay is provided without warranty of any kind, express or '
              'implied, including fitness for a particular purpose. To the '
              'fullest extent permitted by law, the developer is not liable for '
              'any claim, damage, loss of data, or other liability arising from '
              'your use of the app or from your reliance on it.'),
          SectionHeading('Attribution'),
          P('Decay was designed and built by HAMZA POWERPLAYER. Please keep the '
              'name attached to it wherever you share it.'),
        ]),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuietPage(
      title: 'Privacy policy',
      subtitle: 'last updated $_updated',
      children: [
        Prose(children: [
          SectionHeading('In short'),
          P('Decay does not collect your personal data. It has no account, asks '
              'for no login, and talks to no server. There is nothing to opt '
              'out of because there is nothing being collected.'),
          SectionHeading('What is stored, and where'),
          P('The app stores a small amount of information locally on your '
              'device so that it can remember its own life: the moment you '
              'planted your companion, the moments you visited and how long you '
              'stayed, the current stage of its fading, and your '
              'ambient-sound preference. This information never leaves your '
              'device. It is not uploaded, backed up to a server, or shared '
              'with anyone.'),
          SectionHeading('No analytics, no tracking, no third parties'),
          P('Decay contains no analytics SDK, no advertising SDK, no crash '
              'reporting service, no fingerprinting, and no tracking of any '
              'kind. We do not know who you are, where you are, or how often '
              'you open the app, and we could not tell you even if we wanted '
              'to.'),
          SectionHeading('No network requests'),
          P('The app makes no network requests while it runs. Its fonts, '
              'artwork, and ambient sound are bundled with the app and read '
              'directly from your device. Links to the developer\'s email, '
              'WhatsApp, Patreon, and website open outside the app, in your own '
              'browser or mail app, under their own privacy terms.'),
          SectionHeading('Permissions'),
          P('Decay requests no location, contacts, camera, microphone, photo, '
              'or advertising identifier permissions. On Android it may use a '
              'vibration for a single, gentle haptic when a visit is '
              'registered.'),
          SectionHeading('Deleting your data'),
          P('Uninstalling the app, or clearing its storage from your device '
              'settings, permanently deletes everything it holds. Because that '
              'data exists nowhere else, it cannot be recovered by anyone, '
              'including the developer.'),
          SectionHeading('Children'),
          P('Decay is not directed at children under 13, and since it collects '
              'no data at all, it does not knowingly collect anything from '
              'anyone of any age.'),
          SectionHeading('Contact'),
          P('For any privacy question, write to '
              'hamzapowerplayer.global@gmail.com.'),
        ]),
      ],
    );
  }
}

const String _site = 'https://hamzapowerplayer.com';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuietPage(
      title: 'About',
      subtitle: 'one light, left to fade.',
      children: [
        const Prose(children: [
          P('Decay is a small, offline, login-free companion app. It is not a '
              'pet and not a game. It is a single soft light that dims when you '
              'stop visiting and finally goes out, and then leaves you with '
              'something honest.'),
          P('Everything you see is generated on your device, from your own '
              'history. There is no model, no cloud, and no feed.'),
        ]),
        const SectionHeading('Credits'),
        const Prose(children: [
          P('Designed, written and built by HAMZA POWERPLAYER. Type set in '
              'Fraunces and Source Sans 3. Companion artwork and the ambient '
              'tone were generated for this app.'),
        ]),
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
          ),
          child: ListRow(
            first: true,
            title: 'HAMZA POWERPLAYER',
            note: 'hamzapowerplayer.com',
            onPressed: () => launchUrl(Uri.parse(_site), mode: LaunchMode.externalApplication),
          ),
        ),
      ],
    );
  }
}

const String _email = 'hamzapowerplayer.global@gmail.com';
const String _whatsapp = '+923129584661';
const String _patreon = 'https://www.patreon.com/posts/heartfelt-thank-153029964';

class DeveloperSupportScreen extends StatelessWidget {
  const DeveloperSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuietPage(
      title: 'Developer support',
      subtitle: 'made by one person, on purpose.',
      children: [
        const Prose(children: [
          P('Decay is the work of HAMZA POWERPLAYER, built slowly and without '
              'a single analytics SDK in it. If something in it felt broken, '
              'too quiet, or not quite what you expected, you are very welcome '
              'to say so. Bug reports, kind words, and long messages are all '
              'equally fine.'),
        ]),
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
          ),
          child: Column(
            children: [
              ListRow(
                first: true,
                title: 'Email',
                note: _email,
                onPressed: () => launchUrl(Uri.parse('mailto:$_email')),
              ),
              ListRow(
                title: 'WhatsApp',
                note: _whatsapp,
                onPressed: () =>
                    launchUrl(Uri.parse('https://wa.me/923129584661'), mode: LaunchMode.externalApplication),
              ),
              ListRow(
                title: 'Support the developer',
                note: 'patreon',
                onPressed: () => launchUrl(Uri.parse(_patreon), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ),
        const SectionHeading('Thank you'),
        const Prose(children: [
          P('No ratings, no badges, no popups asking anything of you. If you '
              'want to help, the only thing that helps is telling someone you '
              'know about it — and staying with the ones you have already '
              'planted.'),
        ]),
      ],
    );
  }
}
