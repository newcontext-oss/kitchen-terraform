# kitchen-terraform Change Log

<table>
  <thead>
    <tr>
      <th>Version</th>
      <th>Major</th>
      <th>Minor</th>
      <th>Patch</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0.1.2</td>
      <td></td>
      <td></td>
      <td>
        <ul>
          <li>
            Remove enforcement of RubyGems trust policy (thanks
            <a href="https://github.com/fivetwentysix">
              @fivetwentysix
            </a>)
          </li>
          <li>
            Only suggest the LowSecurity RubyGems trust policy; in a
            clean Bundler environment, this is the highest policy that
            can be successfully applied
          </li>
          <li>
            Add links to referenced users' profiles in the Change Log
          </li>
          <li>Display RuboCop Cop names in Guard output</li>
          <li>
            Only enforce code coverage requirements when Guard runs all
            specs
          </li>
          <li>
            Add contributing and developing guides (thanks
            <a href="https://github.com/nictrix">@nictrix</a>)
          </li>
          <li>
            Update example configuration to be compatible with more AWS
            accounts (thanks
            <a href="https://github.com/nictrix">@nictrix</a>)
          </li>
          <li>
            Update example instructions to suggest IAM user creation for
            enhanced security (thanks
            <a href="https://github.com/nictrix">@nictrix</a>)
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>0.1.1</td>
      <td></td>
      <td></td>
      <td>
        <ul>
          <li>
            Lower the development bundle trust policy to MediumSecurity
            due to rubocop-0.42.0 not being signed :crying_cat_face:
          </li>
          <li>
            Replace `0 == fixnum_object` with `fixnum_object.zero?`
          </li>
          <li>Add the LICENSE and README to the gem</li>
          <li>Remove the specs from the gem</li>
          <li>
            Fix the line length of the gem specification signing key
            configuration
          </li>
          <li>
            Correct the reference to `bundle install --trust-profile`
            with `bundle install --trust-policy` in the README (thanks
            <a href="https://github.com/nellshamrell">@nellshamrell</a>
            and <a href="https://github.com/nictrix">@nictrix</a>)
          </li>
          <li>
            Clarify the gem installation instructions in the README
            (thanks <a href="https://github.com/nictrix">@nictrix</a>)
          </li>
          <li>Add Nick Willever to the gem specification authors</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>0.1.0</td>
      <td></td>
      <td>
        <ul>
          <li>Initial release</li>
        </ul>
      </td>
      <td></td>
    </tr>
  </tbody>
</table>
